from __future__ import annotations

from sqlalchemy import Boolean, String, Text
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base, BigIntPrimaryKeyMixin, TimestampMixin


class Company(BigIntPrimaryKeyMixin, TimestampMixin, Base):
    __tablename__ = "companies"

    company_code: Mapped[str | None] = mapped_column(String(30), unique=True, nullable=True)
    name: Mapped[str] = mapped_column(String(150), index=True)
    english_name: Mapped[str | None] = mapped_column(String(150), nullable=True)
    business_no: Mapped[str | None] = mapped_column(String(20), nullable=True)
    ceo_name: Mapped[str | None] = mapped_column(String(100), nullable=True)
    phone: Mapped[str | None] = mapped_column(String(30), nullable=True)
    email: Mapped[str | None] = mapped_column(String(150), nullable=True)
    postal_code: Mapped[str | None] = mapped_column(String(20), nullable=True)
    address_line1: Mapped[str | None] = mapped_column(String(255), nullable=True)
    address_line2: Mapped[str | None] = mapped_column(String(255), nullable=True)
    is_shipper: Mapped[bool] = mapped_column(Boolean, default=False)
    is_consignee: Mapped[bool] = mapped_column(Boolean, default=False)
    is_carrier: Mapped[bool] = mapped_column(Boolean, default=False)
    is_warehouse: Mapped[bool] = mapped_column(Boolean, default=False)
    is_internal: Mapped[bool] = mapped_column(Boolean, default=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    memo: Mapped[str | None] = mapped_column(Text, nullable=True)

    users = relationship("User", back_populates="company")
    drivers = relationship("Driver", back_populates="company")
    vehicles = relationship("Vehicle", back_populates="company")

