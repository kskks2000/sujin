from __future__ import annotations

from pathlib import Path

from test_postgres_connection import get_connection

ROOT_DIR = Path(__file__).resolve().parents[1]
SCHEMA_PATH = ROOT_DIR / "sql" / "001_initial_schema.sql"


def main() -> None:
    sql = SCHEMA_PATH.read_text(encoding="utf-8")

    with get_connection() as connection:
        connection.autocommit = True
        with connection.cursor() as cursor:
            cursor.execute(sql)

    print(f"Applied schema from: {SCHEMA_PATH}")


if __name__ == "__main__":
    main()
