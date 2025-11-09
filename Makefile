# ---------- Config ----------
APP_NAME        ?= flask-app
PORT            ?= 5000

# VERSION is read from ./VERSION file; defaults to 1.0.0 if absent
VERSION_FILE    := VERSION
VERSION         := $(shell test -f $(VERSION_FILE) && cat $(VERSION_FILE) || echo 1.0.0)

IMAGE_LATEST    := $(APP_NAME):latest
IMAGE_VERSIONED := $(APP_NAME):$(VERSION)
CONTAINER_NAME  := $(APP_NAME)-container

SHELL := /bin/bash

.PHONY: build rebuild run restart stop logs ps clean \
        print-version bump-patch bump-minor bump-major \
        release release-patch release-minor release-major \
        tag list-images help
# -------- Build --------
build:
	docker build -t $(IMAGE_LATEST) .

rebuild:
	docker build --no-cache -t $(IMAGE_LATEST) .

# -------- Run / Dev Loop --------
run:
	@echo "Starting $(CONTAINER_NAME) on http://localhost:$(PORT) ..."
	docker run -d -p $(PORT):5000 --name $(CONTAINER_NAME) $(IMAGE_LATEST)

restart: stop run

stop:
	- docker stop $(CONTAINER_NAME)
	- docker rm $(CONTAINER_NAME)

logs:
	docker logs -f $(CONTAINER_NAME)

ps:
	docker ps --filter "name=$(CONTAINER_NAME)"

# -------- Cleanup --------
clean: stop
	- docker rmi $(IMAGE_LATEST) >/dev/null 2>&1 || true
	- docker rmi $(IMAGE_VERSIONED) >/dev/null 2>&1 || true

# -------- Tagging (local only) --------
tag:
	@echo "Tagging $(IMAGE_LATEST) -> $(IMAGE_VERSIONED)"
	docker tag $(IMAGE_LATEST) $(IMAGE_VERSIONED)

list-images:
	@echo "📦 Available images for $(APP_NAME):"
	@docker images | grep $(APP_NAME) || echo "⚠️ No images found for $(APP_NAME)"

print-version:
	@echo "Current version: $(VERSION)"

# ---------- Version bump helpers ----------
# Portable bump function (POSIX sh-friendly via bash SHELL)
define BUMP_TO
	@old=$$(test -f $(VERSION_FILE) && cat $(VERSION_FILE) || echo 1.0.0); \
	IFS=.; set -- $$old; MAJOR=$$1; MINOR=$$2; PATCH=$$3; \
	case "$(1)" in \
	  patch) PATCH=$$((PATCH+1));; \
	  minor) MINOR=$$((MINOR+1)); PATCH=0;; \
	  major) MAJOR=$$((MAJOR+1)); MINOR=0; PATCH=0;; \
	esac; \
	new="$$MAJOR.$$MINOR.$$PATCH"; \
	echo $$new > $(VERSION_FILE); \
	echo "Version bumped: $$old -> $$new"
endef

bump-patch:
	$(call BUMP_TO,patch)

bump-minor:
	$(call BUMP_TO,minor)

bump-major:
	$(call BUMP_TO,major)

# ---------- Release flows ----------
# Uses the VERSION currently in the VERSION file
release:
	@ver=$$(cat $(VERSION_FILE) 2>/dev/null || echo 1.0.0); \
	echo "🚀 Building $(APP_NAME):$$ver and tagging as latest..."; \
	docker build -t $(APP_NAME):$$ver .; \
	docker tag $(APP_NAME):$$ver $(APP_NAME):latest; \
	echo "✅ Done: $(APP_NAME):$$ver + latest"

# Auto-bump + release in one step
release-patch: bump-patch release
release-minor: bump-minor release
release-major: bump-major release

# ---------- Help ----------
help:
	@echo "Targets:"
	@echo "  build / rebuild           Build image as $(IMAGE_LATEST)"
	@echo "  run / restart / stop      Run or manage container on PORT=$(PORT)"
	@echo "  logs / ps                 Tail logs / show container"
	@echo "  clean                     Remove images & container (safe)"
	@echo "  print-version             Show current version (from $(VERSION_FILE))"
	@echo "  bump-patch|minor|major    Bump version file"
	@echo "  release                   Build VERSION in file + tag as latest"
	@echo "  release-patch|minor|major Bump -> build -> tag latest"
	@echo "  tag                       Tag latest as $(IMAGE_VERSIONED)"
	@echo "  list-images               List images for $(APP_NAME)"
	@echo ""
	@echo "Overrides: make PORT=8081 APP_NAME=myapi build"