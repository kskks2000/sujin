from __future__ import annotations

from datetime import datetime

from app.models.enums import DispatchStatus
from app.schemas.common import ORMModel


class DispatchCreate(ORMModel):
    order_id: int
    carrier_company_id: int
    vehicle_id: int | None = None
    driver_id: int | None = None
    status: DispatchStatus = DispatchStatus.ASSIGNED
    assigned_at: datetime
    freight_amount: float = 0
    cost_amount: float = 0
    distance_km: float | None = None
    note: str | None = None


class DispatchRead(DispatchCreate):
    id: int
    dispatch_no: str
    vehicle_no_snapshot: str | None
    driver_name_snapshot: str | None
    driver_phone_snapshot: str | None
    created_at: datetime
    updated_at: datetime


class DispatchBoardRead(ORMModel):
    id: int
    dispatch_no: str
    order_id: int
    order_no: str
    carrier_company_name: str
    vehicle_id: int | None
    vehicle_no: str | None
    driver_id: int | None
    driver_name: str | None
    assigned_at: datetime
    status: DispatchStatus
    freight_amount: float
    cost_amount: float
    note: str | None

