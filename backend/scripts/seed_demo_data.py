from __future__ import annotations

import os
from datetime import UTC, date, datetime, timedelta
from pathlib import Path

import psycopg
from psycopg.rows import dict_row
from test_postgres_connection import get_connection, load_env_file

ROOT_DIR = Path(__file__).resolve().parents[1]


def ensure_company(cursor: psycopg.Cursor[dict], code: str, name: str, **flags: bool) -> int:
    cursor.execute("select id from companies where company_code = %s", (code,))
    row = cursor.fetchone()
    if row:
        return row["id"]

    cursor.execute(
        """
        insert into companies (
            company_code, name, is_shipper, is_consignee, is_carrier, is_internal
        ) values (%s, %s, %s, %s, %s, %s)
        returning id
        """,
        (
            code,
            name,
            flags.get("is_shipper", False),
            flags.get("is_consignee", False),
            flags.get("is_carrier", False),
            flags.get("is_internal", False),
        ),
    )
    return cursor.fetchone()["id"]


def main() -> None:
    load_env_file(ROOT_DIR / ".env")

    from app.core.security import get_password_hash

    with get_connection() as connection:
        with connection.cursor(row_factory=dict_row) as cursor:
            internal_company_id = ensure_company(
                cursor,
                "KC-INTERNAL",
                "KCastle Logistics",
                is_internal=True,
                is_carrier=True,
            )
            shipper_id = ensure_company(cursor, "SHIPPER-001", "Sujin Retail", is_shipper=True)
            consignee_id = ensure_company(
                cursor,
                "CONSIGNEE-001",
                "Busan Outlet",
                is_consignee=True,
            )
            carrier_id = ensure_company(
                cursor,
                "CARRIER-001",
                "Blue Road Transport",
                is_carrier=True,
            )

            cursor.execute("select id from users where login_id = %s", ("admin",))
            admin = cursor.fetchone()
            if admin:
                admin_id = admin["id"]
            else:
                cursor.execute(
                    """
                    insert into users (
                        company_id, login_id, password_hash, name, user_role, email
                    ) values (%s, %s, %s, %s, %s, %s)
                    returning id
                    """,
                    (
                        internal_company_id,
                        "admin",
                        get_password_hash(os.getenv("ADMIN_PASSWORD", "ChangeMe123!")),
                        "System Admin",
                        "ADMIN",
                        "admin@tms.local",
                    ),
                )
                admin_id = cursor.fetchone()["id"]

            cursor.execute("select id from drivers where driver_code = %s", ("DRV-001",))
            driver = cursor.fetchone()
            if driver:
                driver_id = driver["id"]
            else:
                cursor.execute(
                    """
                    insert into drivers (
                        company_id, driver_code, name, phone, employment_type
                    ) values (%s, %s, %s, %s, %s)
                    returning id
                    """,
                    (carrier_id, "DRV-001", "Lee Hyunwoo", "010-3333-1111", "COMPANY_DRIVER"),
                )
                driver_id = cursor.fetchone()["id"]

            cursor.execute("select id from vehicles where vehicle_no = %s", ("83GA1234",))
            vehicle = cursor.fetchone()
            if vehicle:
                vehicle_id = vehicle["id"]
            else:
                cursor.execute(
                    """
                    insert into vehicles (
                        company_id, vehicle_no, vehicle_type, tonnage, is_gps_enabled
                    ) values (%s, %s, %s, %s, %s)
                    returning id
                    """,
                    (carrier_id, "83GA1234", "WING_BODY", 5, True),
                )
                vehicle_id = cursor.fetchone()["id"]

            cursor.execute("select count(*) as count from orders")
            if cursor.fetchone()["count"] == 0:
                now = datetime.now(UTC)
                cursor.execute(
                    """
                    insert into orders (
                        bill_to_company_id, shipper_company_id, consignee_company_id,
                        created_by_user_id, updated_by_user_id,
                        status, service_type, priority, service_date,
                        pickup_window_start, pickup_window_end,
                        delivery_window_start, delivery_window_end,
                        cargo_name, cargo_qty, cargo_unit, cargo_weight_kg,
                        requires_pod, special_instructions
                    ) values (
                        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                    )
                    returning id, order_no
                    """,
                    (
                        shipper_id,
                        shipper_id,
                        consignee_id,
                        admin_id,
                        admin_id,
                        "DISPATCHED",
                        "FTL",
                        2,
                        date.today(),
                        now,
                        now + timedelta(hours=1),
                        now + timedelta(hours=5),
                        now + timedelta(hours=6),
                        "Consumer Goods",
                        120.0,
                        "BOX",
                        3400.0,
                        True,
                        "Morning arrival requested",
                    ),
                )
                order = cursor.fetchone()

                cursor.execute(
                    """
                    insert into order_stops (
                        order_id, sequence_no, stop_type, company_id, name,
                        address_line1, appointment_start_at, appointment_end_at
                    ) values
                        (%s, 1, 'PICKUP', %s, 'Incheon Fulfillment Center', 'Incheon', %s, %s),
                        (%s, 2, 'DROPOFF', %s, 'Busan Outlet', 'Busan', %s, %s)
                    """,
                    (
                        order["id"],
                        shipper_id,
                        now,
                        now + timedelta(hours=1),
                        order["id"],
                        consignee_id,
                        now + timedelta(hours=5),
                        now + timedelta(hours=6),
                    ),
                )

                cursor.execute(
                    """
                    insert into dispatches (
                        order_id, carrier_company_id, vehicle_id, driver_id,
                        assigned_by_user_id, updated_by_user_id, status,
                        vehicle_no_snapshot, driver_name_snapshot, driver_phone_snapshot,
                        assigned_at, freight_amount, cost_amount, distance_km, note
                    ) values (
                        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                    )
                    """,
                    (
                        order["id"],
                        carrier_id,
                        vehicle_id,
                        driver_id,
                        admin_id,
                        admin_id,
                        "IN_TRANSIT",
                        "83GA1234",
                        "Lee Hyunwoo",
                        "010-3333-1111",
                        now,
                        850000.0,
                        670000.0,
                        410.0,
                        "Priority lane assignment",
                    ),
                )

        connection.commit()

    print("Seeded demo data.")


if __name__ == "__main__":
    main()
