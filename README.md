# Cvitanok

[![Tests](https://github.com/oduvan/fastapi-template/actions/workflows/tests.yml/badge.svg)](https://github.com/oduvan/fastapi-template/actions/workflows/tests.yml)
[![Python 3.12](https://img.shields.io/badge/python-3.12-blue.svg)](https://www.python.org/downloads/)
[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![Pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit)](https://github.com/pre-commit/pre-commit)

A modern FastAPI project with full-stack features including WebSocket support, background task processing, user authentication, and admin panel.

## Tech Stack

- **FastAPI** - Modern, fast web framework for building APIs
- **PostgreSQL** - Relational database with async support via asyncpg
- **Redis** - In-memory data store for caching and message broker
- **Celery** - Distributed task queue for background jobs
- **SQLAlchemy** - SQL toolkit and ORM with async support
- **Alembic** - Database migrations
- **fastapi-users** - User authentication and management
- **sqladmin** - Admin panel for database models
- **Jinja2** - Template engine
- **WebSocket** - Real-time bidirectional communication
- **Pydantic** - Data validation and settings management
- **pytest** - Testing framework with async support
- **fastapi-cache2** - Caching with Redis backend
- **httpx** - Async HTTP client
- **Docker Compose** - Multi-container orchestration

## Project Structure

```
cvitanok/
├── alembic/                    # Database migrations
│   ├── versions/              # Migration files
│   └── env.py                 # Alembic environment configuration
├── app/
│   ├── api/
│   │   └── v1/
│   │       └── endpoints.py   # API endpoints
│   ├── core/
│   │   ├── config.py          # Application settings
│   │   └── security.py        # Authentication setup
│   ├── db/
│   │   ├── base.py            # Import all models for Alembic
│   │   └── session.py         # Database session
│   ├── models/
│   │   └── user.py            # User model
│   ├── schemas/
│   │   └── user.py            # Pydantic schemas
│   ├── services/              # Business logic
│   ├── tasks/
│   │   ├── celery_app.py      # Celery configuration
│   │   └── tasks.py           # Celery tasks
│   ├── templates/             # Jinja2 templates
│   ├── static/                # Static files
│   ├── admin.py               # Admin panel setup
│   └── main.py                # FastAPI application
├── tests/
│   ├── api/                   # API tests
│   ├── unit/                  # Unit tests
│   ├── integration/           # Integration tests
│   └── conftest.py            # Pytest fixtures
├── docker-compose.yml         # Docker services
├── Dockerfile                 # Application container
├── requirements.txt           # Python dependencies
├── pytest.ini                 # Pytest configuration
├── alembic.ini                # Alembic configuration
├── .env.example               # Environment variables example
└── README.md                  # This file
```

## Getting Started

### Prerequisites

- Docker and Docker Compose
- Python 3.12+ (for local development)
- Make (optional, for using Makefile commands)

### Setup

1. Clone the repository:
```bash
git clone git@github.com:oduvan/fastapi-template.git
cd fastapi-template
```

2. Create environment file:
```bash
cp .env.example .env
```

3. Update the `.env` file with your configuration, especially change the `SECRET_KEY`.

### Quick Start with Make

The project includes a comprehensive Makefile for easy management. View all available commands:

```bash
make help
```

**Initial setup:**
```bash
make install    # Build, start services, and run migrations
```

**Common commands:**
```bash
make up         # Start all services
make down       # Stop all services
make restart    # Restart all services
make ps         # Show service status
make logs       # Show all logs
make test       # Run tests
make health     # Check service health
```

**Pre-commit setup (recommended for development):**
```bash
# One-command setup of development environment
make setup-dev

# Activate the dev environment
source .venv-dev/bin/activate  # On Windows: .venv-dev\Scripts\activate
```

Pre-commit will automatically run on every commit to check:
- Code formatting (Black)
- Linting (Ruff)
- YAML/JSON/TOML syntax
- Trailing whitespace
- Large files
- Security issues (Bandit)

**Note:**
- Pre-commit runs in your local environment, not in Docker
- It will use your local Python version (Python 3.8+ required)
- The Docker containers run Python 3.12, but pre-commit uses your local Python
- Keep `.venv-dev` activated while developing

### Running with Docker

Start all services:
```bash
docker-compose up -d
```

This will start:
- PostgreSQL database (port 5432)
- Redis (port 6379)
- FastAPI web server (port 8000)
- Celery worker
- Celery beat scheduler

### Database Migrations

Create initial migration:
```bash
docker-compose exec web alembic revision --autogenerate -m "Initial migration"
```

Run migrations:
```bash
docker-compose exec web alembic upgrade head
```

### Access Points

- **API Documentation**: http://localhost:8000/docs
- **Alternative API Docs**: http://localhost:8000/redoc
- **Admin Panel**: http://localhost:8000/admin
- **Root Endpoint**: http://localhost:8000/

### WebSocket Example

Connect to WebSocket endpoint:
```javascript
const ws = new WebSocket('ws://localhost:8000/api/v1/ws');
ws.onmessage = (event) => {
    console.log('Message from server:', event.data);
};
ws.send('Hello Server!');
```

## Development

### Local Setup (without Docker)

1. Create virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Update `.env` with local database URLs:
```env
DATABASE_URL=postgresql+asyncpg://postgres:postgres@localhost:5432/cvitanok
REDIS_URL=redis://localhost:6379/0
```

4. Run services:
```bash
# Start FastAPI server
uvicorn app.main:app --reload

# Start Celery worker (separate terminal)
celery -A app.tasks.celery_app worker --loglevel=info

# Start Celery beat (separate terminal)
celery -A app.tasks.celery_app beat --loglevel=info
```

### Running Tests

```bash
# Run all tests
docker-compose exec web pytest

# Run with coverage
docker-compose exec web pytest --cov

# Run specific test file
docker-compose exec web pytest tests/api/test_endpoints.py

# Run with markers
docker-compose exec web pytest -m unit
docker-compose exec web pytest -m integration
```

## Features

### Authentication

The project uses `fastapi-users` for authentication with JWT tokens:

- **Register**: `POST /auth/register`
- **Login**: `POST /auth/jwt/login`
- **Logout**: `POST /auth/jwt/logout`
- **Reset Password**: `POST /auth/forgot-password`
- **Verify Email**: `POST /auth/request-verify-token`

### Admin Panel

Access the admin panel at `/admin` to manage:
- Users
- Other models (add them to `app/admin.py`)

### Caching

Redis-based caching is configured and ready to use:

```python
from fastapi_cache.decorator import cache

@router.get("/items")
@cache(expire=60)
async def get_items():
    return {"items": []}
```

### Background Tasks

Celery tasks are defined in `app/tasks/tasks.py`:

```python
from app.tasks.tasks import example_task

# Trigger task
result = example_task.delay(2, 3)
```

### WebSocket

WebSocket endpoint is available at `/api/v1/ws` for real-time communication.

## Environment Variables

Key environment variables (see `.env.example` for full list):

- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `CELERY_BROKER_URL` - Celery broker URL
- `CELERY_RESULT_BACKEND` - Celery result backend URL
- `SECRET_KEY` - Secret key for JWT tokens
- `BACKEND_CORS_ORIGINS` - Allowed CORS origins

## Makefile Commands

The project includes a comprehensive Makefile with commands organized by category. Run `make help` to see all available commands.

### Docker Operations
```bash
make build          # Build all Docker images
make up             # Start all services
make down           # Stop all services
make restart        # Restart all services
make ps             # Show service status
make rebuild        # Rebuild everything from scratch
```

### Development
```bash
make dev            # Start development environment
make serve          # Start services and show web logs
make watch          # Watch logs for all services
make health         # Check health of all services
```

### Logs
```bash
make logs                # Show all logs
make logs-web            # Show web service logs
make logs-db             # Show database logs
make logs-celery-worker  # Show Celery worker logs
make logs-celery-beat    # Show Celery beat logs
```

### Shell Access
```bash
make shell          # Access web container shell
make shell-db       # Access PostgreSQL shell
make shell-redis    # Access Redis CLI
```

### Database Migrations
```bash
make migrate           # Apply migrations
make migrate-auto      # Generate new migration (prompts for message)
make migrate-down      # Rollback one migration
make migrate-history   # Show migration history
make migrate-current   # Show current migration
```

### Database Operations
```bash
make db-backup     # Backup database to backups/ directory
make db-restore    # Restore from backup (usage: make db-restore FILE=backups/file.sql)
make db-reset      # Reset database (WARNING: destroys all data)
```

### Testing
```bash
make test              # Run all tests
make test-cov          # Run tests with coverage report
make test-unit         # Run unit tests only
make test-integration  # Run integration tests only
make quick-test        # Quick test without coverage
```

### Celery Operations
```bash
make celery-worker   # Start Celery worker (foreground)
make celery-beat     # Start Celery beat (foreground)
make celery-flower   # Start Flower monitoring tool
make celery-status   # Check worker status
make celery-purge    # Purge all tasks
```

### Code Quality & Pre-commit
```bash
make setup-dev           # Setup dev environment (.venv-dev) with pre-commit
make pre-commit-install  # Install pre-commit hooks (if already have .venv-dev)
make pre-commit-run      # Run pre-commit on all files
make pre-commit-update   # Update pre-commit hooks
make format              # Format code with black
make lint                # Lint code with ruff
make lint-fix            # Lint and auto-fix code with ruff
```

### Cleanup
```bash
make clean           # Stop and remove containers
make clean-volumes   # Remove all volumes (WARNING: destroys data)
make clean-all       # Full cleanup including volumes
```

## License

MIT
