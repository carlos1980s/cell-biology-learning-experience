from fastapi import FastAPI

from app import __version__
from app.api import admin_router, agents_router, cells_router, sessions_router
from app.config import get_settings
from app.observability.logging import configure_logging
from app.schemas.api import HealthResponse

configure_logging()
settings = get_settings()

app = FastAPI(
    title="Cell Organelle Agents Backend",
    version=__version__,
)


@app.get("/health", response_model=HealthResponse, tags=["health"])
def health() -> HealthResponse:
    return HealthResponse(version=settings.service_version)


app.include_router(sessions_router, prefix=settings.api_prefix)
app.include_router(cells_router, prefix=settings.api_prefix)
app.include_router(agents_router, prefix=settings.api_prefix)
app.include_router(admin_router, prefix=settings.api_prefix)
