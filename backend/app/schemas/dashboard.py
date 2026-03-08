from __future__ import annotations

from app.models.enums import DispatchStatus, OrderStatus
from app.schemas.common import ORMModel


class DashboardOrderPreview(ORMModel):
    id: int
    order_no: str
    bill_to_company_name: str
    pickup_name: str | None
    delivery_name: str | None
    status: OrderStatus


class DashboardDispatchPreview(ORMModel):
    id: int
    dispatch_no: str
    order_no: str
    carrier_company_name: str
    vehicle_no: str | None
    driver_name: str | None
    status: DispatchStatus


class DashboardSummary(ORMModel):
    total_orders: int
    active_orders: int
    completed_orders: int
    active_dispatches_count: int
    available_vehicles: int
    available_drivers: int
    recent_orders: list[DashboardOrderPreview]
    active_dispatches: list[DashboardDispatchPreview]

