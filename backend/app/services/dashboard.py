from __future__ import annotations

from redis.asyncio import Redis
from sqlalchemy import case, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.company import Company
from app.models.dispatch import Dispatch
from app.models.driver import Driver
from app.models.enums import DispatchStatus, OrderStatus
from app.models.order import Order
from app.models.order_stop import OrderStop
from app.models.vehicle import Vehicle
from app.schemas.dashboard import DashboardDispatchPreview, DashboardOrderPreview, DashboardSummary

DASHBOARD_CACHE_KEY = "dashboard:summary"
ACTIVE_ORDER_STATUSES = [
    OrderStatus.REQUESTED,
    OrderStatus.CONFIRMED,
    OrderStatus.DISPATCHING,
    OrderStatus.DISPATCHED,
    OrderStatus.PICKUP_COMPLETED,
    OrderStatus.IN_TRANSIT,
    OrderStatus.DELIVERED,
]
ACTIVE_DISPATCH_STATUSES = [
    DispatchStatus.ASSIGNED,
    DispatchStatus.ACCEPTED,
    DispatchStatus.ENROUTE_PICKUP,
    DispatchStatus.AT_PICKUP,
    DispatchStatus.LOADED,
    DispatchStatus.IN_TRANSIT,
    DispatchStatus.AT_DELIVERY,
    DispatchStatus.POD_UPLOADED,
]


async def invalidate_dashboard_cache(redis_client: Redis | None) -> None:
    if redis_client is None:
        return
    try:
        await redis_client.delete(DASHBOARD_CACHE_KEY)
    except Exception:
        pass


async def build_dashboard_summary(session: AsyncSession) -> DashboardSummary:
    total_orders = int(await session.scalar(select(func.count(Order.id))) or 0)
    active_order_count_query = select(func.count(Order.id)).where(
        Order.status.in_(ACTIVE_ORDER_STATUSES)
    )
    active_orders = int(
        await session.scalar(active_order_count_query) or 0
    )
    completed_order_count_query = select(func.count(Order.id)).where(
        Order.status == OrderStatus.COMPLETED
    )
    completed_orders = int(
        await session.scalar(completed_order_count_query) or 0
    )
    active_dispatches_count = int(
        await session.scalar(
            select(func.count(Dispatch.id)).where(Dispatch.status.in_(ACTIVE_DISPATCH_STATUSES))
        )
        or 0
    )
    available_vehicles = int(
        await session.scalar(select(func.count(Vehicle.id)).where(Vehicle.is_active.is_(True))) or 0
    )
    available_drivers = int(
        await session.scalar(select(func.count(Driver.id)).where(Driver.is_active.is_(True))) or 0
    )

    pickup_stop = OrderStop.__table__.alias("pickup_stop")
    delivery_stop = OrderStop.__table__.alias("delivery_stop")

    recent_order_rows = (
        await session.execute(
            select(
                Order.id,
                Order.order_no,
                Company.name.label("bill_to_company_name"),
                pickup_stop.c.name.label("pickup_name"),
                delivery_stop.c.name.label("delivery_name"),
                Order.status,
            )
            .join(Company, Company.id == Order.bill_to_company_id)
            .outerjoin(
                pickup_stop,
                (pickup_stop.c.order_id == Order.id)
                & (pickup_stop.c.stop_type == "PICKUP")
                & (pickup_stop.c.sequence_no == 1),
            )
            .outerjoin(
                delivery_stop,
                (delivery_stop.c.order_id == Order.id)
                & (delivery_stop.c.stop_type == "DROPOFF"),
            )
            .order_by(Order.created_at.desc())
            .limit(5)
        )
    ).all()

    active_dispatch_rows = (
        await session.execute(
            select(
                Dispatch.id,
                Dispatch.dispatch_no,
                Order.order_no,
                Company.name.label("carrier_company_name"),
                case(
                    (Dispatch.vehicle_no_snapshot.is_not(None), Dispatch.vehicle_no_snapshot),
                    else_=Vehicle.vehicle_no,
                ).label("vehicle_no"),
                case(
                    (Dispatch.driver_name_snapshot.is_not(None), Dispatch.driver_name_snapshot),
                    else_=Driver.name,
                ).label("driver_name"),
                Dispatch.status,
            )
            .join(Order, Order.id == Dispatch.order_id)
            .join(Company, Company.id == Dispatch.carrier_company_id)
            .outerjoin(Vehicle, Vehicle.id == Dispatch.vehicle_id)
            .outerjoin(Driver, Driver.id == Dispatch.driver_id)
            .where(Dispatch.status.in_(ACTIVE_DISPATCH_STATUSES))
            .order_by(Dispatch.assigned_at.desc())
            .limit(5)
        )
    ).all()

    return DashboardSummary(
        total_orders=total_orders,
        active_orders=active_orders,
        completed_orders=completed_orders,
        active_dispatches_count=active_dispatches_count,
        available_vehicles=available_vehicles,
        available_drivers=available_drivers,
        recent_orders=[
            DashboardOrderPreview(
                id=row.id,
                order_no=row.order_no,
                bill_to_company_name=row.bill_to_company_name,
                pickup_name=row.pickup_name,
                delivery_name=row.delivery_name,
                status=row.status,
            )
            for row in recent_order_rows
        ],
        active_dispatches=[
            DashboardDispatchPreview(
                id=row.id,
                dispatch_no=row.dispatch_no,
                order_no=row.order_no,
                carrier_company_name=row.carrier_company_name,
                vehicle_no=row.vehicle_no,
                driver_name=row.driver_name,
                status=row.status,
            )
            for row in active_dispatch_rows
        ],
    )


async def get_dashboard_summary(
    session: AsyncSession,
    redis_client: Redis | None,
) -> DashboardSummary:
    if redis_client is not None:
        try:
            cached = await redis_client.get(DASHBOARD_CACHE_KEY)
            if cached:
                return DashboardSummary.model_validate_json(cached)
        except Exception:
            pass

    summary = await build_dashboard_summary(session)
    if redis_client is not None:
        try:
            await redis_client.set(DASHBOARD_CACHE_KEY, summary.model_dump_json(), ex=30)
        except Exception:
            pass
    return summary
