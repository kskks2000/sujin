from app.core.config import Settings


def test_async_database_url_conversion() -> None:
    settings = Settings(database_url="postgresql://postgres:secret@localhost:5432/tms")
    assert settings.async_database_url == "postgresql+asyncpg://postgres:secret@localhost:5432/tms"

