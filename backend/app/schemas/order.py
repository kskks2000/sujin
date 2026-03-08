from __future__ import annotations

from datetime import date, datetime

from app.models.enums import OrderStatus, ServiceType, StopType, VehicleType
from app.schemas.common import ORMModel


class OrderStopCreate(ORMModel):
    sequence_no: int
    stop_type: StopType
    location_id: int | None = None
    company_id: int | None = None
    name: str
    contact_name: str | None = None
    contact_phone: str | None = None
    postal_code: str | None = None
    address_line1: str
    address_line2: str | None = None
    latitude: float | None = None
    longitude: float | None = None
    appointment_start_at: datetime | None = None
    appointment_end_at: datetime | None = None
    instructions: str | None = None


class OrderCreate(ORMModel):
    external_order_no: str | None = None
    customer_order_no: str | None = None
    bill_to_company_id: int
    shipper_company_id: int | None = None
    consignee_company_id: int | None = None
    status: OrderStatus = OrderStatus.REQUESTED
    service_type: ServiceType = ServiceType.FTL
    priority: int = 3
    service_date: date | None = None
    pickup_window_start: datetime | None = None
    pickup_window_end: datetime | None = None
    delivery_window_start: datetime | None = None
    delivery_window_end: datetime | None = None
    cargo_name: str | None = None
    cargo_qty: float | None = None
    cargo_unit: str | None = None
    cargo_weight_kg: float | None = None
    cargo_volume_cbm: float | None = None
    pallet_count: int | None = None
    requires_pod: bool = False
    vehicle_type_required: VehicleType | None = None
    temperature_min: float | None = None
    temperature_max: float | None = None
    special_instructions: str | None = None
    remark: str | None = None
    stops: list[OrderStopCreate]


class OrderRead(ORMModel):
    id: int
    order_no: str
    bill_to_company_id: int
    shipper_company_id: int | None
    consignee_company_id: int | None
    status: OrderStatus
    service_type: ServiceType
    priority: int
    service_date: date | None
    cargo_name: str | None
    cargo_weight_kg: float | None
    requires_pod: bool
    created_at: datetime
    updated_at: datetime


class OrderListRead(ORMModel):
    id: int
    order_no: str
    bill_to_company_name: str
    shipper_name: str | None
    consignee_name: str | None
    pickup_name: str | None
    delivery_name: str | None
    status: OrderStatus
    service_date: date | None
    cargo_name: str | None
    cargo_weight_kg: float | None

