from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from redis.asyncio import Redis
from sqlalchemy import case, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_redis
from app.db.session import get_db
from app.models.company import Company
from app.models.dispatch import Dispatch
from app.models.driver import Driver
from app.models.order import Order
from app.models.user import User
from app.models.vehicle import Vehicle
from app.schemas.dispatch import DispatchBoardRead, DispatchCreate, DispatchRead
from app.services.dashboard import invalidate_dashboard_cache

router = APIRouter(prefix="/dispatches", tags=["dispatches"])


@router.get("", response_model=list[DispatchBoardRead])
async def list_dispatches(
    _: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> list[DispatchBoardRead]:
    rows = (
        await session.execute(
            select(
                Dispatch.id,
                Dispatch.dispatch_no,
                Dispatch.order_id,
                Order.order_no,
                Company.name.label("carrier_company_name"),
                Dispatch.vehicle_id,
                case(
                    (Dispatch.vehicle_no_snapshot.is_not(None), Dispatch.vehicle_no_snapshot),
                    else_=Vehicle.vehicle_no,
                ).label("vehicle_no"),
                Dispatch.driver_id,
                case(
                    (Dispatch.driver_name_snapshot.is_not(None), Dispatch.driver_name_snapshot),
                    else_=Driver.name,
                ).label("driver_name"),
                Dispatch.assigned_at,
                Dispatch.status,
                Dispatch.freight_amount,
                Dispatch.cost_amount,
                Dispatch.note,
            )
            .join(Order, Order.id == Dispatch.order_id)
            .join(Company, Company.id == Dispatch.carrier_company_id)
            .outerjoin(Vehicle, Vehicle.id == Dispatch.vehicle_id)
            .outerjoin(Driver, Driver.id == Dispatch.driver_id)
            .order_by(Dispatch.assigned_at.desc())
        )
    ).all()

    return [
        DispatchBoardRead(
            id=row.id,
            dispatch_no=row.dispatch_no,
            order_id=row.order_id,
            order_no=row.order_no,
            carrier_company_name=row.carrier_company_name,
            vehicle_id=row.vehicle_id,
            vehicle_no=row.vehicle_no,
            driver_id=row.driver_id,
            driver_name=row.driver_name,
            assigned_at=row.assigned_at,
            status=row.status,
            freight_amount=float(row.freight_amount),
            cost_amount=float(row.cost_amount),
            note=row.note,
        )
        for row in rows
    ]


@router.post("", response_model=DispatchRead, status_code=status.HTTP_201_CREATED)
async def create_dispatch(
    payload: DispatchCreate,
    current_user: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
    redis_client: Annotated[Redis | None, Depends(get_redis)],
) -> DispatchRead:
    order = await session.get(Order, payload.order_id)
    if order is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Order not found.")

    carrier_company = await session.get(Company, payload.carrier_company_id)
    if carrier_company is None:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Carrier not found.")

    vehicle = None
    if payload.vehicle_id is not None:
        vehicle = await session.get(Vehicle, payload.vehicle_id)
        if vehicle is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Vehicle not found.")

    driver = None
    if payload.driver_id is not None:
        driver = await session.get(Driver, payload.driver_id)
        if driver is None:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Driver not found.")

    dispatch = Dispatch(
        order_id=payload.order_id,
        carrier_company_id=payload.carrier_company_id,
        vehicle_id=payload.vehicle_id,
        driver_id=payload.driver_id,
        assigned_by_user_id=current_user.id,
        updated_by_user_id=current_user.id,
        status=payload.status,
        vehicle_no_snapshot=vehicle.vehicle_no if vehicle else None,
        driver_name_snapshot=driver.name if driver else None,
        driver_phone_snapshot=driver.phone if driver else None,
        assigned_at=payload.assigned_at,
        freight_amount=payload.freight_amount,
        cost_amount=payload.cost_amount,
        distance_km=payload.distance_km,
        note=payload.note,
    )
    session.add(dispatch)
    await session.flush()

    await session.commit()
    await session.refresh(dispatch)
    await invalidate_dashboard_cache(redis_client)
    return DispatchRead.model_validate(dispatch)
