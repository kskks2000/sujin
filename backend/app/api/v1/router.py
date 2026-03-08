from fastapi import APIRouter

from app.api.v1 import auth, companies, dashboard, dispatches, drivers, orders, vehicles

api_router = APIRouter()
api_router.include_router(auth.router)
api_router.include_router(companies.router)
api_router.include_router(drivers.router)
api_router.include_router(vehicles.router)
api_router.include_router(orders.router)
api_router.include_router(dispatches.router)
api_router.include_router(dashboard.router)

