from __future__ import annotations

from sqlalchemy import Boolean, Enum, ForeignKey, Numeric, SmallInteger, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, BigIntPrimaryKeyMixin, TimestampMixin
from app.models.enums import VehicleType


class Vehicle(BigIntPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "vehicles"

    company_id: Mapped[int] = mapped_column(ForeignKey("companies.id"), index=True)
    vehicle_no: Mapped[str] = mapped_column(String(30), unique=True, index=True)
    vehicle_type: Mapped[VehicleType] = mapped_column(Enum(VehicleType, name="vehicle_type"))
    tonnage: Mapped[float | None] = mapped_column(Numeric(10, 2), nullable=True)
    capacity_cbm: Mapped[float | None] = mapped_column(Numeric(10, 2), nullable=True)
    max_weight_kg: Mapped[float | None] = mapped_column(Numeric(12, 2), nullable=True)
    vehicle_year: Mapped[int | None] = mapped_column(SmallInteger, nullable=True)
    registration_no: Mapped[str | None] = mapped_column(String(50), nullable=True)
    is_refrigerated: Mapped[bool] = mapped_column(Boolean, default=False)
    is_gps_enabled: Mapped[bool] = mapped_column(Boolean, default=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    memo: Mapped[str | None] = mapped_column(Text, nullable=True)

    company = relationship("Company", back_populates="vehicles")
    dispatches = relationship("Dispatch", back_populates="vehicle")

