.PHONY: help setup up down restart logs status shell run test clean check-docker check-uv check-env

# Load .env (silent include - won't fail if missing)
-include .env
export

# Default target
help:
	@echo "FBO Development Commands"
	@echo "========================"
	@echo ""
	@echo "Setup:"
	@echo "  make setup          Install dependencies and initialize environment"
	@echo ""
	@echo "Services:"
	@echo "  make up             Start Neo4j"
	@echo "  make down           Stop Neo4j"
	@echo "  make restart        Restart Neo4j"
	@echo "  make logs           Tail Neo4j logs"
	@echo "  make status         Show service status"
	@echo "  make shell          Open Neo4j Cypher shell"
	@echo ""
	@echo "Development:"
	@echo "  make run            Run the application"
	@echo "  make test           Run tests"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean          Stop services and remove volumes (DELETES DATA)"
	@echo ""
	@echo "Neo4j Access:"
	@echo "  Browser: http://localhost:$(NEO4J_HTTP_PORT)"
	@echo "  Bolt:    bolt://localhost:$(NEO4J_BOLT_PORT)"
	@echo "  User:    neo4j"

# Dependency checks
check-docker:
	@command -v docker > /dev/null 2>&1 || { echo "Error: Docker is not installed"; exit 1; }
	@docker info > /dev/null 2>&1 || { echo "Error: Docker daemon is not running"; exit 1; }

check-uv:
	@command -v uv > /dev/null 2>&1 || { echo "Error: uv is not installed. Install: curl -LsSf https://astral.sh/uv/install.sh | sh"; exit 1; }

check-env:
	@test -f .env || { echo "Error: .env file not found. Run 'make setup' first."; exit 1; }

# Setup
setup: check-env check-uv
	@echo "Setting up environment..."
	uv sync
	@echo "Setup complete!"

# Services
up: check-env check-docker
	@echo "Starting services..."
	@docker compose up -d 2>&1 | grep -v "No services to build"
	@echo "Waiting for Neo4j to be healthy..."
	@until docker compose exec -T neo4j cypher-shell -u neo4j -p $(NEO4J_PASSWORD) "RETURN 1" > /dev/null 2>&1; do \
		sleep 2; \
		printf "."; \
	done
	@echo ""
	@echo "Neo4j is ready!"
	@echo "  Browser: http://localhost:$(NEO4J_HTTP_PORT)"
	@echo "  Bolt:    bolt://localhost:$(NEO4J_BOLT_PORT)"

down: check-env check-docker
	@docker compose down 2>&1 | grep -v "No services to build"

restart: down up

logs: check-env check-docker
	docker compose logs -f neo4j

status: check-env check-docker
	docker compose ps

shell: check-env check-docker
	docker compose exec neo4j cypher-shell -u neo4j -p $(NEO4J_PASSWORD)

# Development
run: check-env check-uv
	uv run python main.py

test: check-env check-uv
	uv run pytest

# Cleanup
clean: check-env check-docker
	@echo "WARNING: This will delete all Neo4j data!"
	@read -p "Are you sure? [y/N] " confirm && [ "$$confirm" = "y" ] || { echo "Cancelled"; exit 1; }
	docker compose down -v
	@echo "Volumes removed"
