# TMS Backend

FastAPI backend for a TMS aligned to the PostgreSQL schema in `sql/001_initial_schema.sql`.

## Run

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -e .[dev]
uvicorn app.main:app --reload
```

## Helpers

```bash
python scripts/test_postgres_connection.py
python scripts/apply_schema.py
python scripts/seed_demo_data.py
```
