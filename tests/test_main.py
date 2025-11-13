import pytest
from httpx import AsyncClient


@pytest.mark.asyncio
async def test_root_endpoint(client: AsyncClient):
    """Test the root endpoint returns correct JSON response."""
    response = await client.get("/")
    assert response.status_code == 200
    data = response.json()
    assert data["message"] == "Welcome to FastAPI Template"
    assert data["docs"] == "/docs"
    assert data["admin"] == "/admin"
    assert data["welcome"] == "/welcome"


@pytest.mark.asyncio
async def test_welcome_page_renders(client: AsyncClient):
    """Test the welcome page renders successfully."""
    response = await client.get("/welcome")
    assert response.status_code == 200
    assert response.headers["content-type"] == "text/html; charset=utf-8"


@pytest.mark.asyncio
async def test_welcome_page_content(client: AsyncClient):
    """Test the welcome page contains expected content."""
    response = await client.get("/welcome")
    content = response.text

    # Check title
    assert "Welcome - FastAPI Template" in content

    # Check main heading
    assert "Welcome to FastAPI Template!" in content

    # Check navigation links
    assert 'href="/welcome"' in content
    assert 'href="/docs"' in content
    assert 'href="/admin"' in content

    # Check features section
    assert "Features" in content
    assert "FastAPI" in content
    assert "PostgreSQL + SQLAlchemy" in content
    assert "Redis + Celery" in content
    assert "Authentication" in content
    assert "Admin Panel" in content
    assert "WebSocket Support" in content

    # Check quick links section
    assert "Quick Links" in content
    assert "Interactive API Documentation" in content
    assert "Health Check" in content

    # Check project info section
    assert "Project Info" in content
    assert "Version" in content
    assert "Python" in content
    assert "Environment" in content

    # Check getting started section
    assert "Getting Started" in content
    assert "git clone" in content
    assert "make install" in content

    # Check tech stack section
    assert "Tech Stack" in content
    assert "Python 3.14" in content
    assert "Docker" in content
    assert "pytest" in content


@pytest.mark.asyncio
async def test_welcome_page_css_loaded(client: AsyncClient):
    """Test that the CSS file is referenced in the welcome page."""
    response = await client.get("/welcome")
    content = response.text
    assert "/static/css/style.css" in content
