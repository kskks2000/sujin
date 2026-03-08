BEGIN;

-- =========================================================
-- 0) Common trigger function
-- =========================================================
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =========================================================
-- 1) ENUM types
-- =========================================================
DO $$ BEGIN
    CREATE TYPE user_role AS ENUM (
        'SUPER_ADMIN',
        'ADMIN',
        'DISPATCHER',
        'OPS',
        'DRIVER',
        'CS',
        'ACCOUNTING',
        'CUSTOMER'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE vehicle_type AS ENUM (
        'CARGO_VAN',
        'BOX_TRUCK',
        'WING_BODY',
        'TRACTOR',
        'TRAILER',
        'REEFER',
        'FLATBED',
        'TANKER',
        'ETC'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE driver_employment_type AS ENUM (
        'OWNER_OPERATOR',
        'COMPANY_DRIVER',
        'CONTRACTOR'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE order_status AS ENUM (
        'REQUESTED',
        'CONFIRMED',
        'DISPATCHING',
        'DISPATCHED',
        'PICKUP_COMPLETED',
        'IN_TRANSIT',
        'DELIVERED',
        'COMPLETED',
        'CANCELLED'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE dispatch_status AS ENUM (
        'ASSIGNED',
        'ACCEPTED',
        'REJECTED',
        'ENROUTE_PICKUP',
        'AT_PICKUP',
        'LOADED',
        'IN_TRANSIT',
        'AT_DELIVERY',
        'POD_UPLOADED',
        'COMPLETED',
        'CANCELLED'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE stop_type AS ENUM (
        'PICKUP',
        'DROPOFF',
        'WAYPOINT',
        'RETURN'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE location_type AS ENUM (
        'CUSTOMER_SITE',
        'WAREHOUSE',
        'HUB',
        'FACTORY',
        'PORT',
        'ETC'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE service_type AS ENUM (
        'FTL',
        'LTL',
        'EXPRESS',
        'RETURN',
        'TRANSFER',
        'DISTRIBUTION'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE document_type AS ENUM (
        'POD',
        'INVOICE',
        'TAX_INVOICE',
        'CONTRACT',
        'VEHICLE_REGISTRATION',
        'DRIVER_LICENSE',
        'CARGO_PHOTO',
        'OTHER'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE charge_direction AS ENUM (
        'REVENUE',
        'COST'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE charge_type AS ENUM (
        'FREIGHT',
        'TOLL',
        'WAITING',
        'EXTRA_STOP',
        'HANDLING',
        'FUEL_SURCHARGE',
        'FERRY',
        'STORAGE',
        'OTHER'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$ BEGIN
    CREATE TYPE settlement_status AS ENUM (
        'PENDING',
        'CALCULATED',
        'INVOICED',
        'PARTIALLY_PAID',
        'PAID',
        'CANCELLED'
    );
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- =========================================================
-- 2) Sequences
-- =========================================================
CREATE SEQUENCE IF NOT EXISTS seq_order_no START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_dispatch_no START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_settlement_no START WITH 1;

-- =========================================================
-- 3) Master tables
-- =========================================================
CREATE TABLE IF NOT EXISTS companies (
    id                  BIGSERIAL PRIMARY KEY,
    company_code        VARCHAR(30) UNIQUE,
    name                VARCHAR(150) NOT NULL,
    english_name        VARCHAR(150),
    business_no         VARCHAR(20),
    ceo_name            VARCHAR(100),
    phone               VARCHAR(30),
    email               VARCHAR(150),
    postal_code         VARCHAR(20),
    address_line1       VARCHAR(255),
    address_line2       VARCHAR(255),
    is_shipper          BOOLEAN NOT NULL DEFAULT FALSE,
    is_consignee        BOOLEAN NOT NULL DEFAULT FALSE,
    is_carrier          BOOLEAN NOT NULL DEFAULT FALSE,
    is_warehouse        BOOLEAN NOT NULL DEFAULT FALSE,
    is_internal         BOOLEAN NOT NULL DEFAULT FALSE,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    memo                TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS company_contacts (
    id                  BIGSERIAL PRIMARY KEY,
    company_id          BIGINT NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    name                VARCHAR(100) NOT NULL,
    department          VARCHAR(100),
    job_title           VARCHAR(100),
    phone               VARCHAR(30),
    email               VARCHAR(150),
    is_primary          BOOLEAN NOT NULL DEFAULT FALSE,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    memo                TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
    id                  BIGSERIAL PRIMARY KEY,
    company_id          BIGINT REFERENCES companies(id),
    login_id            VARCHAR(50) NOT NULL UNIQUE,
    password_hash       TEXT NOT NULL,
    name                VARCHAR(100) NOT NULL,
    user_role           user_role NOT NULL,
    phone               VARCHAR(30),
    email               VARCHAR(150),
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    last_login_at       TIMESTAMPTZ,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS locations (
    id                  BIGSERIAL PRIMARY KEY,
    company_id          BIGINT REFERENCES companies(id) ON DELETE SET NULL,
    location_type       location_type NOT NULL DEFAULT 'ETC',
    name                VARCHAR(150) NOT NULL,
    contact_name        VARCHAR(100),
    contact_phone       VARCHAR(30),
    postal_code         VARCHAR(20),
    address_line1       VARCHAR(255) NOT NULL,
    address_line2       VARCHAR(255),
    latitude            NUMERIC(10,7),
    longitude           NUMERIC(10,7),
    memo                TEXT,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_locations_latitude
        CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_locations_longitude
        CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
);

CREATE TABLE IF NOT EXISTS drivers (
    id                  BIGSERIAL PRIMARY KEY,
    company_id          BIGINT NOT NULL REFERENCES companies(id),
    user_id             BIGINT UNIQUE REFERENCES users(id) ON DELETE SET NULL,
    driver_code         VARCHAR(30),
    name                VARCHAR(100) NOT NULL,
    phone               VARCHAR(30) NOT NULL,
    license_no          VARCHAR(50),
    license_expiry_date DATE,
    employment_type     driver_employment_type NOT NULL DEFAULT 'COMPANY_DRIVER',
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    memo                TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_drivers_company_code UNIQUE (company_id, driver_code)
);

CREATE TABLE IF NOT EXISTS vehicles (
    id                  BIGSERIAL PRIMARY KEY,
    company_id          BIGINT NOT NULL REFERENCES companies(id),
    vehicle_no          VARCHAR(30) NOT NULL UNIQUE,
    vehicle_type        vehicle_type NOT NULL,
    tonnage             NUMERIC(10,2),
    capacity_cbm        NUMERIC(10,2),
    max_weight_kg       NUMERIC(12,2),
    vehicle_year        SMALLINT,
    registration_no     VARCHAR(50),
    is_refrigerated     BOOLEAN NOT NULL DEFAULT FALSE,
    is_gps_enabled      BOOLEAN NOT NULL DEFAULT FALSE,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE,
    memo                TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_vehicles_tonnage
        CHECK (tonnage IS NULL OR tonnage >= 0),
    CONSTRAINT chk_vehicles_capacity
        CHECK (capacity_cbm IS NULL OR capacity_cbm >= 0),
    CONSTRAINT chk_vehicles_max_weight
        CHECK (max_weight_kg IS NULL OR max_weight_kg >= 0)
);

-- =========================================================
-- 4) Orders / stops / cargo
-- =========================================================
CREATE TABLE IF NOT EXISTS orders (
    id                      BIGSERIAL PRIMARY KEY,
    order_no                VARCHAR(50) NOT NULL UNIQUE
                                DEFAULT ('ORD-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(NEXTVAL('seq_order_no')::TEXT, 6, '0')),
    external_order_no       VARCHAR(50),
    customer_order_no       VARCHAR(50),

    bill_to_company_id      BIGINT NOT NULL REFERENCES companies(id),
    shipper_company_id      BIGINT REFERENCES companies(id),
    consignee_company_id    BIGINT REFERENCES companies(id),

    created_by_user_id      BIGINT REFERENCES users(id) ON DELETE SET NULL,
    updated_by_user_id      BIGINT REFERENCES users(id) ON DELETE SET NULL,

    status                  order_status NOT NULL DEFAULT 'REQUESTED',
    service_type            service_type NOT NULL DEFAULT 'FTL',
    priority                SMALLINT NOT NULL DEFAULT 3,

    service_date            DATE,
    pickup_window_start     TIMESTAMPTZ,
    pickup_window_end       TIMESTAMPTZ,
    delivery_window_start   TIMESTAMPTZ,
    delivery_window_end     TIMESTAMPTZ,
    actual_pickup_at        TIMESTAMPTZ,
    actual_delivery_at      TIMESTAMPTZ,

    cargo_name              VARCHAR(200),
    cargo_qty               NUMERIC(12,3),
    cargo_unit              VARCHAR(20),
    cargo_weight_kg         NUMERIC(12,2),
    cargo_volume_cbm        NUMERIC(12,2),
    pallet_count            INTEGER,

    requires_pod            BOOLEAN NOT NULL DEFAULT FALSE,
    vehicle_type_required   vehicle_type,
    temperature_min         NUMERIC(5,2),
    temperature_max         NUMERIC(5,2),

    special_instructions    TEXT,
    cancel_reason           TEXT,
    remark                  TEXT,

    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_orders_priority
        CHECK (priority BETWEEN 1 AND 5),
    CONSTRAINT chk_orders_pickup_window
        CHECK (pickup_window_start IS NULL OR pickup_window_end IS NULL OR pickup_window_end >= pickup_window_start),
    CONSTRAINT chk_orders_delivery_window
        CHECK (delivery_window_start IS NULL OR delivery_window_end IS NULL OR delivery_window_end >= delivery_window_start),
    CONSTRAINT chk_orders_temperature_range
        CHECK (temperature_min IS NULL OR temperature_max IS NULL OR temperature_min <= temperature_max),
    CONSTRAINT chk_orders_cargo_qty
        CHECK (cargo_qty IS NULL OR cargo_qty >= 0),
    CONSTRAINT chk_orders_cargo_weight
        CHECK (cargo_weight_kg IS NULL OR cargo_weight_kg >= 0),
    CONSTRAINT chk_orders_cargo_volume
        CHECK (cargo_volume_cbm IS NULL OR cargo_volume_cbm >= 0),
    CONSTRAINT chk_orders_pallet_count
        CHECK (pallet_count IS NULL OR pallet_count >= 0)
);

CREATE TABLE IF NOT EXISTS order_stops (
    id                      BIGSERIAL PRIMARY KEY,
    order_id                BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    sequence_no             INTEGER NOT NULL,
    stop_type               stop_type NOT NULL,
    location_id             BIGINT REFERENCES locations(id) ON DELETE SET NULL,
    company_id              BIGINT REFERENCES companies(id) ON DELETE SET NULL,

    name                    VARCHAR(150) NOT NULL,
    contact_name            VARCHAR(100),
    contact_phone           VARCHAR(30),
    postal_code             VARCHAR(20),
    address_line1           VARCHAR(255) NOT NULL,
    address_line2           VARCHAR(255),
    latitude                NUMERIC(10,7),
    longitude               NUMERIC(10,7),

    appointment_start_at    TIMESTAMPTZ,
    appointment_end_at      TIMESTAMPTZ,
    arrived_at              TIMESTAMPTZ,
    departed_at             TIMESTAMPTZ,

    instructions            TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_order_stops_order_seq UNIQUE (order_id, sequence_no),
    CONSTRAINT chk_order_stops_sequence_no
        CHECK (sequence_no > 0),
    CONSTRAINT chk_order_stops_appointment_window
        CHECK (appointment_start_at IS NULL OR appointment_end_at IS NULL OR appointment_end_at >= appointment_start_at),
    CONSTRAINT chk_order_stops_depart_after_arrive
        CHECK (arrived_at IS NULL OR departed_at IS NULL OR departed_at >= arrived_at),
    CONSTRAINT chk_order_stops_latitude
        CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_order_stops_longitude
        CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
);

CREATE TABLE IF NOT EXISTS order_items (
    id                      BIGSERIAL PRIMARY KEY,
    order_id                BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    item_name               VARCHAR(200) NOT NULL,
    item_code               VARCHAR(50),
    quantity                NUMERIC(12,3) NOT NULL DEFAULT 1,
    unit                    VARCHAR(20),
    weight_kg               NUMERIC(12,2),
    volume_cbm              NUMERIC(12,2),
    pallet_count            INTEGER,
    hazardous               BOOLEAN NOT NULL DEFAULT FALSE,
    temperature_controlled  BOOLEAN NOT NULL DEFAULT FALSE,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_order_items_quantity
        CHECK (quantity > 0),
    CONSTRAINT chk_order_items_weight
        CHECK (weight_kg IS NULL OR weight_kg >= 0),
    CONSTRAINT chk_order_items_volume
        CHECK (volume_cbm IS NULL OR volume_cbm >= 0),
    CONSTRAINT chk_order_items_pallet_count
        CHECK (pallet_count IS NULL OR pallet_count >= 0)
);

-- =========================================================
-- 5) Dispatch / status history
-- =========================================================
CREATE TABLE IF NOT EXISTS dispatches (
    id                      BIGSERIAL PRIMARY KEY,
    dispatch_no             VARCHAR(50) NOT NULL UNIQUE
                                DEFAULT ('DSP-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(NEXTVAL('seq_dispatch_no')::TEXT, 6, '0')),
    order_id                BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    carrier_company_id      BIGINT NOT NULL REFERENCES companies(id),

    vehicle_id              BIGINT REFERENCES vehicles(id),
    driver_id               BIGINT REFERENCES drivers(id),

    assigned_by_user_id     BIGINT REFERENCES users(id) ON DELETE SET NULL,
    updated_by_user_id      BIGINT REFERENCES users(id) ON DELETE SET NULL,

    status                  dispatch_status NOT NULL DEFAULT 'ASSIGNED',

    vehicle_no_snapshot     VARCHAR(30),
    driver_name_snapshot    VARCHAR(100),
    driver_phone_snapshot   VARCHAR(30),

    assigned_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    accepted_at             TIMESTAMPTZ,
    pickup_arrived_at       TIMESTAMPTZ,
    loaded_at               TIMESTAMPTZ,
    departed_at             TIMESTAMPTZ,
    delivery_arrived_at     TIMESTAMPTZ,
    completed_at            TIMESTAMPTZ,
    cancelled_at            TIMESTAMPTZ,

    cancel_reason           TEXT,
    freight_amount          NUMERIC(14,2) NOT NULL DEFAULT 0,
    cost_amount             NUMERIC(14,2) NOT NULL DEFAULT 0,
    distance_km             NUMERIC(10,2),
    note                    TEXT,

    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_dispatches_freight_amount
        CHECK (freight_amount >= 0),
    CONSTRAINT chk_dispatches_cost_amount
        CHECK (cost_amount >= 0),
    CONSTRAINT chk_dispatches_distance
        CHECK (distance_km IS NULL OR distance_km >= 0),
    CONSTRAINT chk_dispatches_accept_after_assign
        CHECK (accepted_at IS NULL OR accepted_at >= assigned_at),
    CONSTRAINT chk_dispatches_complete_after_assign
        CHECK (completed_at IS NULL OR completed_at >= assigned_at),
    CONSTRAINT chk_dispatches_cancel_after_assign
        CHECK (cancelled_at IS NULL OR cancelled_at >= assigned_at)
);

CREATE TABLE IF NOT EXISTS order_status_history (
    id                      BIGSERIAL PRIMARY KEY,
    order_id                BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    from_status             order_status,
    to_status               order_status NOT NULL,
    changed_by_user_id      BIGINT REFERENCES users(id) ON DELETE SET NULL,
    reason                  TEXT,
    changed_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS dispatch_status_history (
    id                      BIGSERIAL PRIMARY KEY,
    dispatch_id             BIGINT NOT NULL REFERENCES dispatches(id) ON DELETE CASCADE,
    from_status             dispatch_status,
    to_status               dispatch_status NOT NULL,
    changed_by_user_id      BIGINT REFERENCES users(id) ON DELETE SET NULL,
    reason                  TEXT,
    changed_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =========================================================
-- 6) Revenue / cost / settlement
-- =========================================================
CREATE TABLE IF NOT EXISTS order_charges (
    id                      BIGSERIAL PRIMARY KEY,
    order_id                BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    dispatch_id             BIGINT REFERENCES dispatches(id) ON DELETE SET NULL,
    direction               charge_direction NOT NULL,
    charge_type             charge_type NOT NULL,
    party_company_id        BIGINT NOT NULL REFERENCES companies(id),
    description             VARCHAR(200),
    quantity                NUMERIC(12,3) NOT NULL DEFAULT 1,
    unit_price              NUMERIC(14,2) NOT NULL DEFAULT 0,
    supply_amount           NUMERIC(14,2) NOT NULL DEFAULT 0,
    tax_amount              NUMERIC(14,2) NOT NULL DEFAULT 0,
    total_amount            NUMERIC(14,2) GENERATED ALWAYS AS (supply_amount + tax_amount) STORED,
    currency_code           CHAR(3) NOT NULL DEFAULT 'KRW',
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_order_charges_quantity
        CHECK (quantity >= 0),
    CONSTRAINT chk_order_charges_unit_price
        CHECK (unit_price >= 0),
    CONSTRAINT chk_order_charges_supply_amount
        CHECK (supply_amount >= 0),
    CONSTRAINT chk_order_charges_tax_amount
        CHECK (tax_amount >= 0)
);

CREATE TABLE IF NOT EXISTS settlements (
    id                      BIGSERIAL PRIMARY KEY,
    settlement_no           VARCHAR(50) NOT NULL UNIQUE
                                DEFAULT ('STL-' || TO_CHAR(CURRENT_DATE, 'YYYYMMDD') || '-' || LPAD(NEXTVAL('seq_settlement_no')::TEXT, 6, '0')),
    order_id                BIGINT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    dispatch_id             BIGINT REFERENCES dispatches(id) ON DELETE SET NULL,
    company_id              BIGINT NOT NULL REFERENCES companies(id),
    direction               charge_direction NOT NULL,
    status                  settlement_status NOT NULL DEFAULT 'PENDING',
    invoice_no              VARCHAR(50),
    tax_invoice_no          VARCHAR(50),
    issue_date              DATE,
    due_date                DATE,
    paid_at                 TIMESTAMPTZ,
    supply_amount           NUMERIC(14,2) NOT NULL DEFAULT 0,
    tax_amount              NUMERIC(14,2) NOT NULL DEFAULT 0,
    total_amount            NUMERIC(14,2) GENERATED ALWAYS AS (supply_amount + tax_amount) STORED,
    note                    TEXT,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_settlements_supply_amount
        CHECK (supply_amount >= 0),
    CONSTRAINT chk_settlements_tax_amount
        CHECK (tax_amount >= 0),
    CONSTRAINT chk_settlements_due_after_issue
        CHECK (issue_date IS NULL OR due_date IS NULL OR due_date >= issue_date)
);

-- =========================================================
-- 7) Attachments / GPS / audit
-- =========================================================
CREATE TABLE IF NOT EXISTS attachments (
    id                      BIGSERIAL PRIMARY KEY,
    order_id                BIGINT REFERENCES orders(id) ON DELETE CASCADE,
    dispatch_id             BIGINT REFERENCES dispatches(id) ON DELETE CASCADE,
    document_type           document_type NOT NULL DEFAULT 'OTHER',
    file_name               VARCHAR(255) NOT NULL,
    file_url                TEXT NOT NULL,
    file_size_bytes         BIGINT,
    mime_type               VARCHAR(100),
    uploaded_by_user_id     BIGINT REFERENCES users(id) ON DELETE SET NULL,
    uploaded_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    description             TEXT,
    CONSTRAINT chk_attachments_parent
        CHECK (order_id IS NOT NULL OR dispatch_id IS NOT NULL),
    CONSTRAINT chk_attachments_file_size
        CHECK (file_size_bytes IS NULL OR file_size_bytes >= 0)
);

CREATE TABLE IF NOT EXISTS vehicle_position_logs (
    id                      BIGSERIAL PRIMARY KEY,
    dispatch_id             BIGINT REFERENCES dispatches(id) ON DELETE SET NULL,
    vehicle_id              BIGINT NOT NULL REFERENCES vehicles(id) ON DELETE CASCADE,
    driver_id               BIGINT REFERENCES drivers(id) ON DELETE SET NULL,
    latitude                NUMERIC(10,7) NOT NULL,
    longitude               NUMERIC(10,7) NOT NULL,
    speed_kph               NUMERIC(6,2),
    heading                 NUMERIC(6,2),
    captured_at             TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_vehicle_position_logs_latitude
        CHECK (latitude BETWEEN -90 AND 90),
    CONSTRAINT chk_vehicle_position_logs_longitude
        CHECK (longitude BETWEEN -180 AND 180),
    CONSTRAINT chk_vehicle_position_logs_speed
        CHECK (speed_kph IS NULL OR speed_kph >= 0)
);

CREATE TABLE IF NOT EXISTS audit_logs (
    id                      BIGSERIAL PRIMARY KEY,
    table_name              VARCHAR(100) NOT NULL,
    record_id               BIGINT,
    action                  VARCHAR(30) NOT NULL,
    changed_by_user_id      BIGINT REFERENCES users(id) ON DELETE SET NULL,
    old_data                JSONB,
    new_data                JSONB,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =========================================================
-- 8) Indexes
-- =========================================================
CREATE INDEX IF NOT EXISTS idx_companies_name
    ON companies (name);

CREATE INDEX IF NOT EXISTS idx_companies_business_no
    ON companies (business_no);

CREATE INDEX IF NOT EXISTS idx_company_contacts_company_primary
    ON company_contacts (company_id, is_primary);

CREATE UNIQUE INDEX IF NOT EXISTS uq_company_contacts_one_primary
    ON company_contacts (company_id)
    WHERE is_primary = TRUE;

CREATE INDEX IF NOT EXISTS idx_users_company_role
    ON users (company_id, user_role);

CREATE INDEX IF NOT EXISTS idx_locations_company_name
    ON locations (company_id, name);

CREATE INDEX IF NOT EXISTS idx_drivers_company_active
    ON drivers (company_id, is_active);

CREATE INDEX IF NOT EXISTS idx_vehicles_company_active
    ON vehicles (company_id, is_active);

CREATE INDEX IF NOT EXISTS idx_orders_status_service_date
    ON orders (status, service_date);

CREATE INDEX IF NOT EXISTS idx_orders_bill_to_company
    ON orders (bill_to_company_id);

CREATE INDEX IF NOT EXISTS idx_orders_shipper_company
    ON orders (shipper_company_id);

CREATE INDEX IF NOT EXISTS idx_orders_consignee_company
    ON orders (consignee_company_id);

CREATE INDEX IF NOT EXISTS idx_orders_customer_order_no
    ON orders (customer_order_no);

CREATE INDEX IF NOT EXISTS idx_order_stops_company_stop_type
    ON order_stops (company_id, stop_type);

CREATE INDEX IF NOT EXISTS idx_order_items_order_id
    ON order_items (order_id);

CREATE INDEX IF NOT EXISTS idx_dispatches_order_status
    ON dispatches (order_id, status);

CREATE INDEX IF NOT EXISTS idx_dispatches_carrier_status
    ON dispatches (carrier_company_id, status);

CREATE INDEX IF NOT EXISTS idx_dispatches_vehicle_status
    ON dispatches (vehicle_id, status);

CREATE INDEX IF NOT EXISTS idx_dispatches_driver_status
    ON dispatches (driver_id, status);

CREATE INDEX IF NOT EXISTS idx_order_status_history_order_changed_at
    ON order_status_history (order_id, changed_at DESC);

CREATE INDEX IF NOT EXISTS idx_dispatch_status_history_dispatch_changed_at
    ON dispatch_status_history (dispatch_id, changed_at DESC);

CREATE INDEX IF NOT EXISTS idx_order_charges_order_direction
    ON order_charges (order_id, direction);

CREATE INDEX IF NOT EXISTS idx_order_charges_party_company
    ON order_charges (party_company_id);

CREATE INDEX IF NOT EXISTS idx_settlements_company_status_due_date
    ON settlements (company_id, status, due_date);

CREATE INDEX IF NOT EXISTS idx_settlements_order_direction
    ON settlements (order_id, direction);

CREATE INDEX IF NOT EXISTS idx_attachments_order_id
    ON attachments (order_id);

CREATE INDEX IF NOT EXISTS idx_attachments_dispatch_id
    ON attachments (dispatch_id);

CREATE INDEX IF NOT EXISTS idx_vehicle_position_logs_vehicle_captured_at
    ON vehicle_position_logs (vehicle_id, captured_at DESC);

CREATE INDEX IF NOT EXISTS idx_vehicle_position_logs_dispatch_captured_at
    ON vehicle_position_logs (dispatch_id, captured_at DESC);

CREATE INDEX IF NOT EXISTS idx_audit_logs_table_record_created_at
    ON audit_logs (table_name, record_id, created_at DESC);

-- =========================================================
-- 9) updated_at triggers
-- =========================================================
DROP TRIGGER IF EXISTS trg_companies_set_updated_at ON companies;
CREATE TRIGGER trg_companies_set_updated_at
BEFORE UPDATE ON companies
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_company_contacts_set_updated_at ON company_contacts;
CREATE TRIGGER trg_company_contacts_set_updated_at
BEFORE UPDATE ON company_contacts
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_users_set_updated_at ON users;
CREATE TRIGGER trg_users_set_updated_at
BEFORE UPDATE ON users
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_locations_set_updated_at ON locations;
CREATE TRIGGER trg_locations_set_updated_at
BEFORE UPDATE ON locations
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_drivers_set_updated_at ON drivers;
CREATE TRIGGER trg_drivers_set_updated_at
BEFORE UPDATE ON drivers
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_vehicles_set_updated_at ON vehicles;
CREATE TRIGGER trg_vehicles_set_updated_at
BEFORE UPDATE ON vehicles
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_orders_set_updated_at ON orders;
CREATE TRIGGER trg_orders_set_updated_at
BEFORE UPDATE ON orders
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_order_stops_set_updated_at ON order_stops;
CREATE TRIGGER trg_order_stops_set_updated_at
BEFORE UPDATE ON order_stops
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_order_items_set_updated_at ON order_items;
CREATE TRIGGER trg_order_items_set_updated_at
BEFORE UPDATE ON order_items
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_dispatches_set_updated_at ON dispatches;
CREATE TRIGGER trg_dispatches_set_updated_at
BEFORE UPDATE ON dispatches
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_order_charges_set_updated_at ON order_charges;
CREATE TRIGGER trg_order_charges_set_updated_at
BEFORE UPDATE ON order_charges
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_settlements_set_updated_at ON settlements;
CREATE TRIGGER trg_settlements_set_updated_at
BEFORE UPDATE ON settlements
FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMIT;

