from __future__ import annotations

from app.models.enums import UserRole
from app.schemas.common import ORMModel


class LoginRequest(ORMModel):
    login_id: str
    password: str


class UserRead(ORMModel):
    id: int
    company_id: int | None
    login_id: str
    name: str
    user_role: UserRole
    phone: str | None
    email: str | None
    is_active: bool


class TokenResponse(ORMModel):
    access_token: str
    token_type: str = "bearer"
    user: UserRead

