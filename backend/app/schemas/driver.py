from __future__ import annotations

from datetime import date, datetime

from app.models.enums import DriverEmploymentType
from app.schemas.common import ORMModel


class DriverCreate(ORMModel):
    company_id: int
    user_id: int | None = None
    driver_code: str | None = None
    name: str
    phone: str
    license_no: str | None = None
    license_expiry_date: date | None = None
    employment_type: DriverEmploymentType = DriverEmploymentType.COMPANY_DRIVER
    is_active: bool = True
    memo: str | None = None


class DriverRead(DriverCreate):
    id: int
    created_at: datetime
    updated_at: datetime

