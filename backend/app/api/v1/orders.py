from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from redis.asyncio import Redis
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_redis
from app.db.session import get_db
from app.models.company import Company
from app.models.order import Order
from app.models.order_stop import OrderStop
from app.models.user import User
from app.schemas.order import OrderCreate, OrderListRead, OrderRead
from app.services.dashboard import invalidate_dashboard_cache

router = APIRouter(prefix="/orders", tags=["orders"])


@router.get("", response_model=list[OrderListRead])
async def list_orders(
    _: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> list[OrderListRead]:
    pickup_stop = OrderStop.__table__.alias("pickup_stop")
    delivery_stop = OrderStop.__table__.alias("delivery_stop")
    shipper = Company.__table__.alias("shipper_company")
    consignee = Company.__table__.alias("consignee_company")

    rows = (
        await session.execute(
            select(
                Order.id,
                Order.order_no,
                Company.name.label("bill_to_company_name"),
                shipper.c.name.label("shipper_name"),
                consignee.c.name.label("consignee_name"),
                pickup_stop.c.name.label("pickup_name"),
                delivery_stop.c.name.label("delivery_name"),
                Order.status,
                Order.service_date,
                Order.cargo_name,
                Order.cargo_weight_kg,
            )
            .join(Company, Company.id == Order.bill_to_company_id)
            .outerjoin(shipper, shipper.c.id == Order.shipper_company_id)
            .outerjoin(consignee, consignee.c.id == Order.consignee_company_id)
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
        )
    ).all()

    return [
        OrderListRead(
            id=row.id,
            order_no=row.order_no,
            bill_to_company_name=row.bill_to_company_name,
            shipper_name=row.shipper_name,
            consignee_name=row.consignee_name,
            pickup_name=row.pickup_name,
            delivery_name=row.delivery_name,
            status=row.status,
            service_date=row.service_date,
            cargo_name=row.cargo_name,
            cargo_weight_kg=float(row.cargo_weight_kg) if row.cargo_weight_kg is not None else None,
        )
        for row in rows
    ]


@router.post("", response_model=OrderRead, status_code=status.HTTP_201_CREATED)
async def create_order(
    payload: OrderCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
    redis_client: Annotated[Redis | None, Depends(get_redis)],
) -> OrderRead:
    bill_to_company = await session.get(Company, payload.bill_to_company_id)
    if bill_to_company is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Bill-to company not found.",
        )

    order = Order(
        external_order_no=payload.external_order_no,
        customer_order_no=payload.customer_order_no,
        bill_to_company_id=payload.bill_to_company_id,
        shipper_company_id=payload.shipper_company_id,
        consignee_company_id=payload.consignee_company_id,
        created_by_user_id=current_user.id,
        updated_by_user_id=current_user.id,
        status=payload.status,
        service_type=payload.service_type,
        priority=payload.priority,
        service_date=payload.service_date,
        pickup_window_start=payload.pickup_window_start,
        pickup_window_end=payload.pickup_window_end,
        delivery_window_start=payload.delivery_window_start,
        delivery_window_end=payload.delivery_window_end,
        cargo_name=payload.cargo_name,
        cargo_qty=payload.cargo_qty,
        cargo_unit=payload.cargo_unit,
        cargo_weight_kg=payload.cargo_weight_kg,
        cargo_volume_cbm=payload.cargo_volume_cbm,
        pallet_count=payload.pallet_count,
        requires_pod=payload.requires_pod,
        vehicle_type_required=payload.vehicle_type_required,
        temperature_min=payload.temperature_min,
        temperature_max=payload.temperature_max,
        special_instructions=payload.special_instructions,
        remark=payload.remark,
    )
    session.add(order)
    await session.flush()
    session.add_all([OrderStop(order_id=order.id, **stop.model_dump()) for stop in payload.stops])

    await session.commit()
    await session.refresh(order)
    await invalidate_dashboard_cache(redis_client)
    return OrderRead.model_validate(order)
