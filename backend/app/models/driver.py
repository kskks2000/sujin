from __future__ import annotations

from datetime import date

from sqlalchemy import Boolean, Date, Enum, ForeignKey, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, BigIntPrimaryKeyMixin, TimestampMixin
from app.models.enums import DriverEmploymentType


class Driver(BigIntPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "drivers"

    company_id: Mapped[int] = mapped_column(ForeignKey("companies.id"), index=True)
    user_id: Mapped[int | None] = mapped_column(ForeignKey("users.id"), unique=True, nullable=True)
    driver_code: Mapped[str | None] = mapped_column(String(30), nullable=True)
    name: Mapped[str] = mapped_column(String(100), index=True)
    phone: Mapped[str] = mapped_column(String(30))
    license_no: Mapped[str | None] = mapped_column(String(50), nullable=True)
    license_expiry_date: Mapped[date | None] = mapped_column(Date, nullable=True)
    employment_type: Mapped[DriverEmploymentType] = mapped_column(
        Enum(DriverEmploymentType, name="driver_employment_type"),
        default=DriverEmploymentType.COMPANY_DRIVER,
    )
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    memo: Mapped[str | None] = mapped_column(Text, nullable=True)

    company = relationship("Company", back_populates="drivers")
    user = relationship("User", back_populates="driver")
    dispatches = relationship("Dispatch", back_populates="driver")

