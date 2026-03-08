from __future__ import annotations

from datetime import datetime

from app.schemas.common import ORMModel


class CompanyCreate(ORMModel):
    company_code: str | None = None
    name: str
    english_name: str | None = None
    business_no: str | None = None
    ceo_name: str | None = None
    phone: str | None = None
    email: str | None = None
    postal_code: str | None = None
    address_line1: str | None = None
    address_line2: str | None = None
    is_shipper: bool = False
    is_consignee: bool = False
    is_carrier: bool = False
    is_warehouse: bool = False
    is_internal: bool = False
    is_active: bool = True
    memo: str | None = None


class CompanyRead(CompanyCreate):
    id: int
    created_at: datetime
    updated_at: datetime

