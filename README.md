# Sujin TMS Monorepo

Production-oriented TMS starter built with Flutter, FastAPI, PostgreSQL, Redis, Docker, and AWS.

## Structure

- `backend`: FastAPI API mapped to the PostgreSQL TMS schema
- `apps/mobile`: Flutter operations app
- `infra/aws/terraform`: ECS Fargate, RDS PostgreSQL, ElastiCache Redis baseline
- `docs`: architecture notes

## Database baseline

The authoritative schema is [backend/sql/001_initial_schema.sql](/C:/kcastle/codex/sujin/backend/sql/001_initial_schema.sql).

Local PostgreSQL connection is configured in [backend/.env](/C:/kcastle/codex/sujin/backend/.env).

## Backend run

```bash
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -e .[dev]
uvicorn app.main:app --reload
```

Optional:

```bash
python scripts/apply_schema.py
python scripts/seed_demo_data.py
```

FastAPI docs:

- [http://localhost:8000/docs](http://localhost:8000/docs)

Default local admin after seeding:

- `login_id`: `admin`
- `password`: `ChangeMe123!`

## Flutter run

```bash
cd apps/mobile
flutter pub get
flutter run
```

Default API base URL in the login form is `http://localhost:8000/api/v1`.

For Android emulator, use `http://10.0.2.2:8000/api/v1`.

## Docker

```bash
docker compose up --build
```

## AWS target shape

- Application Load Balancer
- ECS Fargate
- RDS PostgreSQL
- ElastiCache Redis
- ECR
- CloudWatch Logs

