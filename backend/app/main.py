from __future__ import annotations

from contextlib import asynccontextmanager
from pathlib import Path
from time import time_ns

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse
from starlette.responses import Response
from fastapi.staticfiles import StaticFiles
from redis.asyncio import Redis

from app.api.v1.router import api_router
from app.core.config import get_settings


class NoCacheStaticFiles(StaticFiles):
    async def get_response(self, path: str, scope) -> Response:
        response = await super().get_response(path, scope)
        response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
        response.headers["Pragma"] = "no-cache"
        response.headers["Expires"] = "0"
        return response


@asynccontextmanager
async def lifespan(app: FastAPI):
    settings = get_settings()
    redis_client: Redis | None = None

    try:
        redis_client = Redis.from_url(settings.redis_url, encoding="utf-8", decode_responses=True)
        await redis_client.ping()
    except Exception:
        redis_client = None

    app.state.redis = redis_client
    yield

    if redis_client is not None:
        await redis_client.aclose()


def create_app() -> FastAPI:
    settings = get_settings()
    app = FastAPI(title=settings.app_name, lifespan=lifespan)
    web_build_dir = Path(__file__).resolve().parents[2] / "apps" / "mobile" / "build" / "web"

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_origin_regex=settings.cors_origin_regex,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    app.include_router(api_router, prefix=settings.api_v1_prefix)

    if web_build_dir.exists():
        app.mount("/app", NoCacheStaticFiles(directory=web_build_dir, html=True), name="tms-web")

        @app.get("/app")
        async def app_root() -> RedirectResponse:
            return RedirectResponse(url="/app/")

        @app.get("/mobile")
        async def mobile_root() -> RedirectResponse:
            response = RedirectResponse(url=f"/app/?v={time_ns()}")
            response.headers["Cache-Control"] = "no-store, no-cache, must-revalidate, max-age=0"
            response.headers["Pragma"] = "no-cache"
            response.headers["Expires"] = "0"
            return response

    @app.get("/health")
    async def health() -> dict[str, str]:
        return {"status": "ok", "service": settings.app_name}

    @app.get("/")
    async def root() -> dict[str, str]:
        payload = {"name": settings.app_name, "docs": "/docs", "health": "/health"}
        if web_build_dir.exists():
            payload["app"] = "/app/"
        return payload

    return app


app = create_app()
