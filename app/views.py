import platform

from fastapi import APIRouter, Request
from fastapi.templating import Jinja2Templates

from app.core.config import settings

router = APIRouter()
templates = Jinja2Templates(directory="app/templates")


@router.get("/")
async def root():
    return {
        "message": "Welcome to FastAPI Template",
        "docs": "/docs",
        "admin": "/admin",
        "welcome": "/welcome",
    }


@router.get("/welcome")
async def welcome_page(request: Request):
    """Render welcome page with Jinja2 template - example of HTML rendering"""
    features = [
        {
            "name": "FastAPI",
            "description": "Modern, fast web framework for building APIs with automatic OpenAPI docs",
            "docs_url": "https://fastapi.tiangolo.com/",
        },
        {
            "name": "PostgreSQL + SQLAlchemy",
            "description": "Async database support with powerful ORM and migration tools",
            "docs_url": "https://www.sqlalchemy.org/",
        },
        {
            "name": "Redis + Celery",
            "description": "Background task processing and caching for scalable applications",
            "docs_url": "https://docs.celeryq.dev/",
        },
        {
            "name": "Authentication",
            "description": "JWT-based user authentication with fastapi-users",
            "docs_url": "https://fastapi-users.github.io/fastapi-users/",
        },
        {
            "name": "Admin Panel",
            "description": "SQLAdmin for easy database management",
            "docs_url": "https://aminalaee.dev/sqladmin/",
        },
        {
            "name": "WebSocket Support",
            "description": "Real-time bidirectional communication",
            "docs_url": None,
        },
    ]

    tech_stack = [
        "FastAPI",
        "Python 3.14",
        "PostgreSQL",
        "Redis",
        "Celery",
        "SQLAlchemy",
        "Alembic",
        "Pydantic",
        "Docker",
        "pytest",
        "Jinja2",
    ]

    return templates.TemplateResponse(
        request=request,
        name="welcome.html",
        context={
            "features": features,
            "tech_stack": tech_stack,
            "version": settings.VERSION,
            "python_version": platform.python_version(),
            "environment": "development",
            "api_base": settings.API_V1_STR,
        },
    )
