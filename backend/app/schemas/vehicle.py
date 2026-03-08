from __future__ import annotations

from datetime import datetime

from app.models.enums import VehicleType
from app.schemas.common import ORMModel


class VehicleCreate(ORMModel):
    company_id: int
    vehicle_no: str
    vehicle_type: VehicleType
    tonnage: float | None = None
    capacity_cbm: float | None = None
    max_weight_kg: float | None = None
    vehicle_year: int | None = None
    registration_no: str | None = None
    is_refrigerated: bool = False
    is_gps_enabled: bool = False
    is_active: bool = True
    memo: str | None = None


class VehicleRead(VehicleCreate):
    id: int
    created_at: datetime
    updated_at: datetime

