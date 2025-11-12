.PHONY: help build up down restart logs logs-web logs-db logs-celery-worker logs-celery-beat ps shell shell-db test test-cov migrate migrate-auto migrate-down clean clean-volumes rebuild

# Default target
.DEFAULT_GOAL := help

# Variables
DOCKER_COMPOSE = docker compose
DOCKER_EXEC = $(DOCKER_COMPOSE) exec
WEB_SERVICE = web
DB_SERVICE = db
WORKER_SERVICE = celery_worker
BEAT_SERVICE = celery_beat

# Colors for output
BLUE = \033[0;34m
GREEN = \033[0;32m
YELLOW = \033[0;33m
RED = \033[0;31m
NC = \033[0m # No Color

help: ## Show this help message
	@echo "$(BLUE)Available targets:$(NC)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(NC) %s\n", $$1, $$2}'

# Docker Commands
build: ## Build all Docker images
	@echo "$(BLUE)Building Docker images...$(NC)"
	$(DOCKER_COMPOSE) build

up: ## Start all services in detached mode
	@echo "$(BLUE)Starting services...$(NC)"
	$(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)Services started!$(NC)"
	@$(MAKE) ps

up-build: ## Build and start all services
	@echo "$(BLUE)Building and starting services...$(NC)"
	$(DOCKER_COMPOSE) up -d --build
	@echo "$(GREEN)Services started!$(NC)"
	@$(MAKE) ps

down: ## Stop all services
	@echo "$(YELLOW)Stopping services...$(NC)"
	$(DOCKER_COMPOSE) down
	@echo "$(GREEN)Services stopped!$(NC)"

restart: down up ## Restart all services

ps: ## Show status of all services
	@$(DOCKER_COMPOSE) ps

# Logs
logs: ## Show logs for all services
	$(DOCKER_COMPOSE) logs -f

logs-web: ## Show logs for web service
	$(DOCKER_COMPOSE) logs -f $(WEB_SERVICE)

logs-db: ## Show logs for database service
	$(DOCKER_COMPOSE) logs -f $(DB_SERVICE)

logs-celery-worker: ## Show logs for Celery worker
	$(DOCKER_COMPOSE) logs -f $(WORKER_SERVICE)

logs-celery-beat: ## Show logs for Celery beat
	$(DOCKER_COMPOSE) logs -f $(BEAT_SERVICE)

# Shell Access
shell: ## Access shell in web container
	@echo "$(BLUE)Accessing web container shell...$(NC)"
	$(DOCKER_EXEC) $(WEB_SERVICE) /bin/bash

shell-db: ## Access PostgreSQL shell
	@echo "$(BLUE)Accessing database shell...$(NC)"
	$(DOCKER_EXEC) $(DB_SERVICE) psql -U postgres -d cvitanok

shell-redis: ## Access Redis CLI
	@echo "$(BLUE)Accessing Redis CLI...$(NC)"
	$(DOCKER_EXEC) redis redis-cli

# Database Migrations
migrate: ## Apply database migrations
	@echo "$(BLUE)Applying migrations...$(NC)"
	$(DOCKER_EXEC) $(WEB_SERVICE) alembic upgrade head
	@echo "$(GREEN)Migrations applied!$(NC)"

migrate-auto: ## Generate new migration automatically
	@echo "$(BLUE)Generating new migration...$(NC)"
	@read -p "Migration message: " msg; \
	$(DOCKER_EXEC) $(WEB_SERVICE) alembic revision --autogenerate -m "$$msg"
	@echo "$(GREEN)Migration generated!$(NC)"

migrate-down: ## Rollback one migration
	@echo "$(YELLOW)Rolling back one migration...$(NC)"
	$(DOCKER_EXEC) $(WEB_SERVICE) alembic downgrade -1
	@echo "$(GREEN)Migration rolled back!$(NC)"

migrate-history: ## Show migration history
	$(DOCKER_EXEC) $(WEB_SERVICE) alembic history

migrate-current: ## Show current migration
	$(DOCKER_EXEC) $(WEB_SERVICE) alembic current

# Testing
test: ## Run tests
	@echo "$(BLUE)Running tests...$(NC)"
	$(DOCKER_EXEC) $(WEB_SERVICE) pytest -v

test-cov: ## Run tests with coverage report
	@echo "$(BLUE)Running tests with coverage...$(NC)"
	$(DOCKER_EXEC) $(WEB_SERVICE) pytest -v --cov --cov-report=term-missing

test-unit: ## Run unit tests only
	@echo "$(BLUE)Running unit tests...$(NC)"
	$(DOCKER_EXEC) $(WEB_SERVICE) pytest -v -m unit

test-integration: ## Run integration tests only
	@echo "$(BLUE)Running integration tests...$(NC)"
	$(DOCKER_EXEC) $(WEB_SERVICE) pytest -v -m integration

# Code Quality & Pre-commit
setup-dev: ## Setup development environment with pre-commit
	@echo "$(BLUE)Setting up development environment...$(NC)"
	@if [ -d ".venv-dev" ]; then \
		echo "$(YELLOW).venv-dev already exists. Skipping creation.$(NC)"; \
	else \
		echo "$(BLUE)Creating virtual environment .venv-dev...$(NC)"; \
		python3 -m venv .venv-dev; \
	fi
	@echo "$(BLUE)Installing development tools...$(NC)"
	@. .venv-dev/bin/activate && pip install --upgrade pip && pip install -r requirements-dev.txt
	@echo "$(BLUE)Installing pre-commit hooks...$(NC)"
	@. .venv-dev/bin/activate && pre-commit install
	@echo "$(GREEN)Development environment ready!$(NC)"
	@echo "$(BLUE)Activate with: source .venv-dev/bin/activate$(NC)"

pre-commit-install: ## Install pre-commit hooks
	@echo "$(BLUE)Installing pre-commit hooks...$(NC)"
	pre-commit install
	@echo "$(GREEN)Pre-commit hooks installed!$(NC)"

pre-commit-run: ## Run pre-commit on all files
	@echo "$(BLUE)Running pre-commit on all files...$(NC)"
	pre-commit run --all-files

pre-commit-update: ## Update pre-commit hooks
	@echo "$(BLUE)Updating pre-commit hooks...$(NC)"
	pre-commit autoupdate

format: ## Format code with black
	@echo "$(BLUE)Formatting code...$(NC)"
	black app tests

lint: ## Lint code with ruff
	@echo "$(BLUE)Linting code...$(NC)"
	ruff check app tests

lint-fix: ## Lint and fix code with ruff
	@echo "$(BLUE)Linting and fixing code...$(NC)"
	ruff check --fix app tests

# Database Operations
db-reset: ## Reset database (WARNING: destroys all data)
	@echo "$(RED)WARNING: This will destroy all data!$(NC)"
	@read -p "Are you sure? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		$(MAKE) down; \
		docker volume rm cvitanok_postgres_data 2>/dev/null || true; \
		$(MAKE) up; \
		sleep 5; \
		$(MAKE) migrate; \
		echo "$(GREEN)Database reset complete!$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled.$(NC)"; \
	fi

db-backup: ## Backup database to backups/db_backup_YYYYMMDD_HHMMSS.sql
	@echo "$(BLUE)Creating database backup...$(NC)"
	@mkdir -p backups
	@BACKUP_FILE="backups/db_backup_$$(date +%Y%m%d_%H%M%S).sql"; \
	docker compose exec -T $(DB_SERVICE) pg_dump -U postgres cvitanok > $$BACKUP_FILE; \
	echo "$(GREEN)Backup created: $$BACKUP_FILE$(NC)"

db-restore: ## Restore database from backup (usage: make db-restore FILE=backups/db_backup.sql)
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Error: Please specify FILE=path/to/backup.sql$(NC)"; \
		exit 1; \
	fi
	@echo "$(BLUE)Restoring database from $(FILE)...$(NC)"
	@cat $(FILE) | docker compose exec -T $(DB_SERVICE) psql -U postgres cvitanok
	@echo "$(GREEN)Database restored!$(NC)"

# Celery Commands
celery-worker: ## Start Celery worker (foreground)
	$(DOCKER_EXEC) $(WEB_SERVICE) celery -A app.tasks.celery_app worker --loglevel=info

celery-beat: ## Start Celery beat (foreground)
	$(DOCKER_EXEC) $(WEB_SERVICE) celery -A app.tasks.celery_app beat --loglevel=info

celery-flower: ## Start Flower (Celery monitoring tool)
	@echo "$(BLUE)Starting Flower on http://localhost:5555$(NC)"
	$(DOCKER_EXEC) $(WEB_SERVICE) celery -A app.tasks.celery_app flower

celery-purge: ## Purge all Celery tasks
	@echo "$(YELLOW)Purging all Celery tasks...$(NC)"
	$(DOCKER_EXEC) $(WEB_SERVICE) celery -A app.tasks.celery_app purge -f
	@echo "$(GREEN)Tasks purged!$(NC)"

celery-status: ## Check Celery worker status
	$(DOCKER_EXEC) $(WEB_SERVICE) celery -A app.tasks.celery_app inspect active

# Installation & Setup
install: build up migrate ## Initial setup: build, start, and migrate
	@echo "$(GREEN)Installation complete!$(NC)"
	@echo "$(BLUE)API: http://localhost:8000$(NC)"
	@echo "$(BLUE)Docs: http://localhost:8000/docs$(NC)"
	@echo "$(BLUE)Admin: http://localhost:8000/admin$(NC)"

# Cleanup
clean: down ## Stop services and remove containers
	@echo "$(YELLOW)Cleaning up...$(NC)"
	$(DOCKER_COMPOSE) rm -f
	@echo "$(GREEN)Cleanup complete!$(NC)"

clean-volumes: ## Remove all volumes (WARNING: destroys all data)
	@echo "$(RED)WARNING: This will destroy all data!$(NC)"
	@read -p "Are you sure? [y/N]: " confirm; \
	if [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ]; then \
		$(MAKE) down; \
		docker volume rm cvitanok_postgres_data cvitanok_redis_data 2>/dev/null || true; \
		echo "$(GREEN)Volumes removed!$(NC)"; \
	else \
		echo "$(YELLOW)Cancelled.$(NC)"; \
	fi

clean-all: clean clean-volumes ## Remove everything including volumes
	@echo "$(GREEN)Full cleanup complete!$(NC)"

rebuild: clean-volumes build up migrate ## Rebuild everything from scratch
	@echo "$(GREEN)Rebuild complete!$(NC)"

# Development
dev: up-build migrate ## Start development environment
	@echo "$(GREEN)Development environment ready!$(NC)"
	@$(MAKE) logs-web

watch: ## Watch logs for all services
	$(DOCKER_COMPOSE) logs -f

# Health Checks
health: ## Check health of all services
	@echo "$(BLUE)Checking service health...$(NC)"
	@curl -s http://localhost:8000/api/v1/health | python3 -m json.tool && echo "$(GREEN)✓ Web service healthy$(NC)" || echo "$(RED)✗ Web service unhealthy$(NC)"
	@$(DOCKER_COMPOSE) exec $(DB_SERVICE) pg_isready -U postgres > /dev/null 2>&1 && echo "$(GREEN)✓ Database healthy$(NC)" || echo "$(RED)✗ Database unhealthy$(NC)"
	@$(DOCKER_COMPOSE) exec redis redis-cli ping > /dev/null 2>&1 && echo "$(GREEN)✓ Redis healthy$(NC)" || echo "$(RED)✗ Redis unhealthy$(NC)"

# Quick commands
quick-test: ## Quick test (no coverage)
	$(DOCKER_EXEC) $(WEB_SERVICE) pytest -q

serve: up logs-web ## Start services and show web logs

stop: down ## Alias for down
