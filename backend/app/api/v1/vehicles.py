from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, status
from redis.asyncio import Redis
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_redis
from app.db.session import get_db
from app.models.user import User
from app.models.vehicle import Vehicle
from app.schemas.vehicle import VehicleCreate, VehicleRead
from app.services.dashboard import invalidate_dashboard_cache

router = APIRouter(prefix="/vehicles", tags=["vehicles"])


@router.get("", response_model=list[VehicleRead])
async def list_vehicles(
    _: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> list[VehicleRead]:
    vehicles = list(await session.scalars(select(Vehicle).order_by(Vehicle.vehicle_no.asc())))
    return [VehicleRead.model_validate(vehicle) for vehicle in vehicles]


@router.post("", response_model=VehicleRead, status_code=status.HTTP_201_CREATED)
async def create_vehicle(
    payload: VehicleCreate,
    _: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
    redis_client: Annotated[Redis | None, Depends(get_redis)],
) -> VehicleRead:
    vehicle = Vehicle(**payload.model_dump())
    session.add(vehicle)
    await session.commit()
    await session.refresh(vehicle)
    await invalidate_dashboard_cache(redis_client)
    return VehicleRead.model_validate(vehicle)

