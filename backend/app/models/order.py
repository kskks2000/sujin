from __future__ import annotations

from datetime import date, datetime

from sqlalchemy import (
    Boolean,
    Date,
    DateTime,
    Enum,
    ForeignKey,
    Numeric,
    SmallInteger,
    String,
    Text,
)
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, BigIntPrimaryKeyMixin, TimestampMixin
from app.models.enums import OrderStatus, ServiceType, VehicleType


class Order(BigIntPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "orders"

    order_no: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    external_order_no: Mapped[str | None] = mapped_column(String(50), nullable=True)
    customer_order_no: Mapped[str | None] = mapped_column(String(50), nullable=True)
    bill_to_company_id: Mapped[int] = mapped_column(ForeignKey("companies.id"), index=True)
    shipper_company_id: Mapped[int | None] = mapped_column(
        ForeignKey("companies.id"),
        nullable=True,
    )
    consignee_company_id: Mapped[int | None] = mapped_column(
        ForeignKey("companies.id"),
        nullable=True,
    )
    created_by_user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    updated_by_user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), nullable=True)
    status: Mapped[OrderStatus] = mapped_column(
        Enum(OrderStatus, name="order_status"),
        default=OrderStatus.REQUESTED,
        index=True,
    )
    service_type: Mapped[ServiceType] = mapped_column(
        Enum(ServiceType, name="service_type"),
        default=ServiceType.FTL,
    )
    priority: Mapped[int] = mapped_column(SmallInteger, default=3)
    service_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    pickup_window_start: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    pickup_window_end: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    delivery_window_start: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    delivery_window_end: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    actual_pickup_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    actual_delivery_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True,
    )
    cargo_name: Mapped[str | None] = mapped_column(String(200), nullable=True)
    cargo_qty: Mapped[float | None] = mapped_column(Numeric(12, 3), nullable=True)
    cargo_unit: Mapped[str | None] = mapped_column(String(20), nullable=True)
    cargo_weight_kg: Mapped[float | None] = mapped_column(Numeric(12, 2), nullable=True)
    cargo_volume_cbm: Mapped[float | None] = mapped_column(Numeric(12, 2), nullable=True)
    pallet_count: Mapped[int | None] = mapped_column(nullable=True)
    requires_pod: Mapped[bool] = mapped_column(Boolean, default=False)
    vehicle_type_required: Mapped[VehicleType | None] = mapped_column(
        Enum(VehicleType, name="vehicle_type"),
        nullable=True,
    )
    temperature_min: Mapped[float | None] = mapped_column(Numeric(5, 2), nullable=True)
    temperature_max: Mapped[float | None] = mapped_column(Numeric(5, 2), nullable=True)
    special_instructions: Mapped[str | None] = mapped_column(Text, nullable=True)
    cancel_reason: Mapped[str | None] = mapped_column(Text, nullable=True)
    remark: Mapped[str | None] = mapped_column(Text, nullable=True)

    dispatches = relationship("Dispatch", back_populates="order")
    stops = relationship("OrderStop", back_populates="order")
