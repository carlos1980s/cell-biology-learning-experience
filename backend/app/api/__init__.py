from app.api.routes_admin import router as admin_router
from app.api.routes_agents import router as agents_router
from app.api.routes_cells import router as cells_router
from app.api.routes_sessions import router as sessions_router

__all__ = ["admin_router", "agents_router", "cells_router", "sessions_router"]

