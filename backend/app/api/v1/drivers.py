from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, status
from redis.asyncio import Redis
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.api.deps import get_current_user, get_redis
from app.db.session import get_db
from app.models.driver import Driver
from app.models.user import User
from app.schemas.driver import DriverCreate, DriverRead
from app.services.dashboard import invalidate_dashboard_cache

router = APIRouter(prefix="/drivers", tags=["drivers"])


@router.get("", response_model=list[DriverRead])
async def list_drivers(
    _: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
) -> list[DriverRead]:
    drivers = list(await session.scalars(select(Driver).order_by(Driver.name.asc())))
    return [DriverRead.model_validate(driver) for driver in drivers]


@router.post("", response_model=DriverRead, status_code=status.HTTP_201_CREATED)
async def create_driver(
    payload: DriverCreate,
    _: Annotated[User, Depends(get_current_user)],
    session: Annotated[AsyncSession, Depends(get_db)],
    redis_client: Annotated[Redis | None, Depends(get_redis)],
) -> DriverRead:
    driver = Driver(**payload.model_dump())
    session.add(driver)
    await session.commit()
    await session.refresh(driver)
    await invalidate_dashboard_cache(redis_client)
    return DriverRead.model_validate(driver)

