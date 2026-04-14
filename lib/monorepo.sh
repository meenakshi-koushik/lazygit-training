#!/usr/bin/env bash
# lib/monorepo.sh -- Functions to create realistic monorepo directory structures
#
# Usage: source this file after sourcing lib/common.sh

# Create a standard monorepo layout at the given path
# Usage: create_monorepo /path/to/repo
create_monorepo() {
    local repo_path="$1"
    mkdir -p "$repo_path"/{services,libs,infra,docs}

    # Root config files
    cat > "$repo_path/.editorconfig" << 'EOF'
root = true

[*]
indent_style = space
indent_size = 4
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true
EOF

    cat > "$repo_path/Makefile" << 'EOF'
.PHONY: build test lint deploy

build:
	@echo "Building all services..."
	@for dir in services/*/; do \
		echo "  Building $${dir}..."; \
	done

test:
	@echo "Running all tests..."
	@for dir in services/*/; do \
		echo "  Testing $${dir}..."; \
	done

lint:
	@echo "Linting..."

deploy:
	@echo "Deploying..."
EOF

    cat > "$repo_path/README.md" << 'EOF'
# Platform Monorepo

Shared platform services, libraries, and infrastructure.

## Structure

- `services/` -- Microservices
- `libs/` -- Shared libraries
- `infra/` -- Infrastructure as code
- `docs/` -- Documentation
EOF
}

# Add a service with realistic source files
# Usage: add_service /path/to/repo service-name
add_service() {
    local repo_path="$1"
    local name="$2"
    local svc_path="${repo_path}/services/${name}"

    mkdir -p "$svc_path"/{src,tests,config}

    cat > "$svc_path/src/main.py" << EOF
"""${name} service entry point."""

import logging
from .config import Settings
from .routes import create_app

logger = logging.getLogger(__name__)


def main():
    settings = Settings()
    app = create_app(settings)
    logger.info("Starting ${name} service on port %d", settings.port)
    app.run(host="0.0.0.0", port=settings.port)


if __name__ == "__main__":
    main()
EOF

    cat > "$svc_path/src/config.py" << EOF
"""Configuration for ${name} service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/${name}")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
EOF

    cat > "$svc_path/src/routes.py" << EOF
"""HTTP routes for ${name} service."""

from flask import Flask, jsonify


def create_app(settings):
    app = Flask(__name__)

    @app.route("/health")
    def health():
        return jsonify({"status": "healthy", "service": "${name}"})

    @app.route("/api/v1/${name}")
    def index():
        return jsonify({"message": "Welcome to ${name}"})

    return app
EOF

    cat > "$svc_path/src/__init__.py" << 'EOF'
EOF

    cat > "$svc_path/tests/test_routes.py" << EOF
"""Tests for ${name} service routes."""

import pytest
from src.routes import create_app
from src.config import Settings


@pytest.fixture
def client():
    settings = Settings()
    app = create_app(settings)
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "healthy"


def test_index(client):
    response = client.get("/api/v1/${name}")
    assert response.status_code == 200
EOF

    cat > "$svc_path/Dockerfile" << EOF
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ ./src/
EXPOSE 8080
CMD ["python", "-m", "src.main"]
EOF

    cat > "$svc_path/requirements.txt" << 'EOF'
flask==3.0.0
gunicorn==21.2.0
pytest==7.4.3
EOF

    cat > "$svc_path/config/settings.yaml" << EOF
service:
  name: ${name}
  port: 8080
  log_level: INFO

database:
  host: localhost
  port: 5432
  name: ${name}

cache:
  enabled: true
  ttl: 300
EOF
}

# Add a shared library under libs/
# Usage: add_library /path/to/repo lib-name
add_library() {
    local repo_path="$1"
    local name="$2"
    local lib_path="${repo_path}/libs/${name}"

    mkdir -p "$lib_path"/{src,tests}

    cat > "$lib_path/src/${name}.py" << EOF
"""${name} -- shared library."""


class ${name^}Client:
    """Client for ${name} operations."""

    def __init__(self, config=None):
        self.config = config or {}
        self._initialized = False

    def initialize(self):
        """Set up the client connection."""
        self._initialized = True
        return self

    def is_ready(self):
        return self._initialized
EOF

    cat > "$lib_path/src/__init__.py" << EOF
from .${name} import ${name^}Client

__all__ = ["${name^}Client"]
EOF

    cat > "$lib_path/tests/test_${name}.py" << EOF
"""Tests for ${name} library."""

import pytest
from src.${name} import ${name^}Client


def test_client_init():
    client = ${name^}Client()
    assert not client.is_ready()


def test_client_initialize():
    client = ${name^}Client()
    client.initialize()
    assert client.is_ready()
EOF

    cat > "$lib_path/setup.py" << EOF
from setuptools import setup, find_packages

setup(
    name="${name}",
    version="0.1.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
)
EOF
}

# Add infrastructure files
# Usage: add_infra /path/to/repo
add_infra() {
    local repo_path="$1"

    mkdir -p "$repo_path"/infra/{terraform,helm,ci}

    cat > "$repo_path/infra/terraform/main.tf" << 'EOF'
terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "platform-terraform-state"
    key    = "infra/terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./modules/vpc"
  cidr   = var.vpc_cidr
}

module "eks" {
  source     = "./modules/eks"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
}
EOF

    cat > "$repo_path/infra/terraform/variables.tf" << 'EOF'
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "staging"
}
EOF

    cat > "$repo_path/infra/helm/values.yaml" << 'EOF'
replicaCount: 2

image:
  repository: platform/service
  tag: latest
  pullPolicy: IfNotPresent

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

ingress:
  enabled: true
  className: nginx
EOF

    cat > "$repo_path/infra/ci/.gitlab-ci.yml" << 'EOF'
stages:
  - test
  - build
  - deploy

test:
  stage: test
  script:
    - make test

build:
  stage: build
  script:
    - make build

deploy:
  stage: deploy
  script:
    - make deploy
  only:
    - main
EOF
}
