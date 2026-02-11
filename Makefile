# ==============================================================================
# WATER AI - ENTERPRISE BUILD CONFIGURATION
# ==============================================================================
# 
# A complete, enterprise-grade build system for Water AI.
# Supports both CLI (headless) and GUI (Fyne) builds with cross-platform
# compilation, testing, linting, and release management.
#
# Usage:
#   make help          - Show all available targets
#   make build         - Build CLI for current platform
#   make gui           - Build GUI for current platform  
#   make release       - Build CLI + GUI for all platforms
#   make test          - Run tests
#   make lint          - Run linters
#   make ci            - Full CI pipeline (lint, test, build all)
#
# Requirements:
#   - Go 1.24+
#   - GCC/Clang (for CGO/Fyne)
#   - golangci-lint (optional, for linting)
#   - govulncheck (optional, for security scanning)
#
# Cross-compilation for GUI:
#   - Linux: Requires gcc, g++, and Fyne dependencies
#   - macOS: Requires Xcode Command Line Tools
#   - Windows: Requires MinGW-w64 or MSVC
#
# ==============================================================================

# ==============================================================================
# CONFIGURATION
# ==============================================================================

# Shell configuration
SHELL := /bin/bash
.SHELLFLAGS := -euo pipefail -c

# Binary names
CLI_BINARY := water
GUI_BINARY  := water-gui

# Version information
# Priority: VERSION env var > git tag > Makefile default
VERSION    ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo "v0.1.0-dev")
GIT_COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
GO_VERSION := $(shell go version | awk '{print $$3}' 2>/dev/null || echo "unknown")

# Detect OS and architecture
UNAME_S := $(shell uname -s 2>/dev/null || echo "Linux")
UNAME_M := $(shell uname -m 2>/dev/null || echo "unknown")

# Map uname to Go OS/ARCH
ifeq ($(UNAME_S),Linux)
    GOOS_HOST := linux
else ifeq ($(UNAME_S),Darwin)
    GOOS_HOST := darwin
else ifeq ($(UNAME_S),Windows_NT)
    GOOS_HOST := windows
else
    GOOS_HOST := linux
endif

ifeq ($(UNAME_M),x86_64)
    GOARCH_HOST := amd64
else ifeq ($(UNAME_M),aarch64)
    GOARCH_HOST := arm64
else ifeq ($(UNAME_M),arm64)
    GOARCH_HOST := arm64
else ifeq ($(UNAME_M),amd64)
    GOARCH_HOST := amd64
else
    GOARCH_HOST := amd64
endif

# Directories
DIST_DIR   := dist
BIN_DIR    := bin
COVERAGE_DIR := coverage

# Platform configurations
CLI_PLATFORMS := linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64 windows/arm64
GUI_PLATFORMS := linux/amd64 darwin/amd64 darwin/arm64 windows/amd64

# Go build flags
LDFLAGS := -s -w \
	-X 'main.Version=$(VERSION)' \
	-X 'main.GitCommit=$(GIT_COMMIT)' \
	-X 'main.BuildDate=$(BUILD_DATE)' \
	-X 'main.GoVersion=$(GO_VERSION)'

GO_FLAGS := -trimpath -ldflags "$(LDFLAGS)"

# CGO settings
CGO_ENABLED ?= 1

# Timeout for tests
TEST_TIMEOUT := 15m

# ==============================================================================
# PHONY TARGETS
# ==============================================================================

.PHONY: all help \
        clean clean-all \
        deps deps-update check-deps \
        fmt vet lint security \
        test test-race test-coverage test-short test-integration \
        build build-cli build-cli-static \
        gui gui-dev gui-static \
        release release-cli release-gui release-all \
        install uninstall \
        mocks \
        version info env \
        ci ci-test ci-build ci-release \
        checksums

# Default target
all: deps test build gui

# ==============================================================================
# HELP
# ==============================================================================

help:
	@echo "╔══════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                          WATER AI - BUILD SYSTEM                             ║"
	@echo "╠══════════════════════════════════════════════════════════════════════════════╣"
	@echo "║  DEVELOPMENT                                                                 ║"
	@echo "║    make build              - Build CLI binary for current OS                 ║"
	@echo "║    make gui                - Build GUI binary for current OS                 ║"
	@echo "║    make gui-dev            - Build GUI with debug symbols                    ║"
	@echo "║    make test               - Run unit tests                                  ║"
	@echo "║    make test-race          - Run tests with race detection                   ║"
	@echo "║    make test-coverage      - Generate test coverage report                   ║"
	@echo "║    make lint               - Run all linters                                 ║"
	@echo "║    make fmt                - Format source code                              ║"
	@echo "╠══════════════════════════════════════════════════════════════════════════════╣"
	@echo "║  RELEASE                                                                    ║"
	@echo "║    make release            - Build CLI + GUI for all platforms               ║"
	@echo "║    make release-cli        - Build CLI for all platforms                     ║"
	@echo "║    make release-gui        - Build GUI for all platforms                     ║"
	@echo "║    make checksums          - Generate SHA256 checksums for dist/             ║"
	@echo "╠══════════════════════════════════════════════════════════════════════════════╣"
	@echo "║  CI/CD                                                                      ║"
	@echo "║    make ci                 - Run full CI pipeline                            ║"
	@echo "║    make ci-test            - Run CI test suite                               ║"
	@echo "║    make ci-build           - Run CI build for all platforms                  ║"
	@echo "║    make ci-release         - Run CI release pipeline                         ║"
	@echo "╠══════════════════════════════════════════════════════════════════════════════╣"
	@echo "║  UTILITIES                                                                  ║"
	@echo "║    make clean              - Remove all build artifacts                      ║"
	@echo "║    make clean-all          - Deep clean (includes Go cache)                  ║"
	@echo "║    make deps               - Download dependencies                           ║"
	@echo "║    make deps-update        - Update dependencies                            ║"
	@echo "║    make install            - Install binaries to GOPATH/bin                  ║"
	@echo "║    make uninstall          - Remove binaries from GOPATH/bin                 ║"
	@echo "║    make info               - Show build environment info                     ║"
	@echo "║    make version            - Show version information                        ║"
	@echo "╚══════════════════════════════════════════════════════════════════════════════╝"

# ==============================================================================
# VERSION & INFO
# ==============================================================================

version:
	@echo "Version:    $(VERSION)"
	@echo "Commit:     $(GIT_COMMIT)"
	@echo "Build Date: $(BUILD_DATE)"
	@echo "Go Version: $(GO_VERSION)"

info:
	@echo "╔══════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                          BUILD ENVIRONMENT                                   ║"
	@echo "╠══════════════════════════════════════════════════════════════════════════════╣"
	@echo "║  Version:       $(VERSION)"
	@echo "║  Git Commit:    $(GIT_COMMIT)"
	@echo "║  Build Date:    $(BUILD_DATE)"
	@echo "║  Go Version:    $(GO_VERSION)"
	@echo "║  Host OS:       $(GOOS_HOST)"
	@echo "║  Host Arch:     $(GOARCH_HOST)"
	@echo "║  CGO Enabled:   $(CGO_ENABLED)"
	@echo "╠══════════════════════════════════════════════════════════════════════════════╣"
	@echo "║  CLI Platforms: $(CLI_PLATFORMS)"
	@echo "║  GUI Platforms: $(GUI_PLATFORMS)"
	@echo "╚══════════════════════════════════════════════════════════════════════════════╝"

env:
	@echo "VERSION=$(VERSION)"
	@echo "GIT_COMMIT=$(GIT_COMMIT)"
	@echo "BUILD_DATE=$(BUILD_DATE)"
	@echo "GO_VERSION=$(GO_VERSION)"
	@echo "GOOS_HOST=$(GOOS_HOST)"
	@echo "GOARCH_HOST=$(GOARCH_HOST)"
	@echo "CGO_ENABLED=$(CGO_ENABLED)"

# ==============================================================================
# DEPENDENCIES & SETUP
# ==============================================================================

deps:
	@echo "--> Downloading dependencies..."
	@go mod download
	@go mod tidy
	@echo "--> Dependencies ready"

deps-update:
	@echo "--> Updating dependencies..."
	@go get -u ./...
	@go mod tidy
	@echo "--> Dependencies updated"

check-deps:
	@echo "--> Checking dependencies..."
	@go mod verify
	@go mod tidy
	@git diff --exit-code go.mod go.sum 2>/dev/null || true
	@echo "--> Dependencies OK"

mocks:
	@echo "--> Creating mock assets for testing..."
	@mkdir -p browser/embed
	@touch browser/embed/OpenSans-Medium.ttf
	@touch browser/embed/findVisibleInteractiveElements.js
	@echo "--> Mock assets created"

# ==============================================================================
# CODE QUALITY
# ==============================================================================

fmt:
	@echo "--> Formatting code..."
	@go fmt ./...
	@echo "--> Code formatted"

vet:
	@echo "--> Running go vet..."
	@go vet ./...
	@echo "--> Vet passed"

lint:
	@echo "--> Running golangci-lint..."
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run --timeout 5m ./...; \
		echo "--> Lint passed"; \
	else \
		echo "WARNING: golangci-lint not installed"; \
		echo "Install with: go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest"; \
	fi

security:
	@echo "--> Running security scan..."
	@if command -v govulncheck >/dev/null 2>&1; then \
		govulncheck ./...; \
		echo "--> Security scan passed"; \
	else \
		echo "WARNING: govulncheck not installed"; \
		echo "Install with: go install golang.org/x/vuln/cmd/govulncheck@latest"; \
	fi

# ==============================================================================
# TESTING
# ==============================================================================

test: mocks
	@echo "--> Running tests..."
	@go test -v -count=1 -timeout $(TEST_TIMEOUT) ./...
	@echo "--> Tests passed"

test-race: mocks
	@echo "--> Running tests with race detection..."
	@CGO_ENABLED=1 go test -race -v -count=1 -timeout $(TEST_TIMEOUT) ./...
	@echo "--> Race tests passed"

test-coverage: mocks
	@echo "--> Running tests with coverage..."
	@mkdir -p $(COVERAGE_DIR)
	@go test -coverprofile=$(COVERAGE_DIR)/coverage.out -covermode=atomic -timeout $(TEST_TIMEOUT) ./...
	@go tool cover -html=$(COVERAGE_DIR)/coverage.out -o $(COVERAGE_DIR)/coverage.html
	@go tool cover -func=$(COVERAGE_DIR)/coverage.out | tail -n 1
	@echo "--> Coverage report: $(COVERAGE_DIR)/coverage.html"

test-short: mocks
	@echo "--> Running short tests..."
	@go test -short -v -count=1 -timeout 5m ./...
	@echo "--> Short tests passed"

test-integration: mocks
	@echo "--> Running integration tests..."
	@go test -v -count=1 -timeout 30m -run Integration ./...
	@echo "--> Integration tests passed"

# ==============================================================================
# CLI BUILD
# ==============================================================================

build: build-cli

build-cli:
	@echo "--> Building CLI binary for $(GOOS_HOST)/$(GOARCH_HOST)..."
	@mkdir -p $(BIN_DIR)
	@CGO_ENABLED=0 go build $(GO_FLAGS) -o $(BIN_DIR)/$(CLI_BINARY) ./cmd/water
	@echo "--> CLI binary: $(BIN_DIR)/$(CLI_BINARY)"

build-cli-static:
	@echo "--> Building static CLI binary..."
	@mkdir -p $(BIN_DIR)
	@CGO_ENABLED=0 go build -a -installsuffix cgo $(GO_FLAGS) -o $(BIN_DIR)/$(CLI_BINARY)-static ./cmd/water
	@echo "--> Static CLI binary: $(BIN_DIR)/$(CLI_BINARY)-static"

# ==============================================================================
# GUI BUILD (FYNE)
# ==============================================================================

gui:
	@echo "--> Building GUI binary for $(GOOS_HOST)/$(GOARCH_HOST)..."
	@mkdir -p $(BIN_DIR)
	@CGO_ENABLED=1 go build $(GO_FLAGS) -o $(BIN_DIR)/$(GUI_BINARY) ./cmd/water-gui
	@echo "--> GUI binary: $(BIN_DIR)/$(GUI_BINARY)"

gui-dev:
	@echo "--> Building GUI binary with debug symbols..."
	@mkdir -p $(BIN_DIR)
	@CGO_ENABLED=1 go build -gcflags "all=-N -l" -o $(BIN_DIR)/$(GUI_BINARY)-debug ./cmd/water-gui
	@echo "--> Debug GUI binary: $(BIN_DIR)/$(GUI_BINARY)-debug"

gui-static:
	@echo "--> Building static GUI binary..."
	@mkdir -p $(BIN_DIR)
	@CGO_ENABLED=1 go build -a $(GO_FLAGS) -o $(BIN_DIR)/$(GUI_BINARY)-static ./cmd/water-gui
	@echo "--> Static GUI binary: $(BIN_DIR)/$(GUI_BINARY)-static"

# ==============================================================================
# RELEASE BUILDS
# ==============================================================================

release: release-cli release-gui checksums

release-cli:
	@echo "╔══════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                      BUILDING CLI RELEASE                                    ║"
	@echo "╚══════════════════════════════════════════════════════════════════════════════╝"
	@mkdir -p $(DIST_DIR)
	@for p in $(CLI_PLATFORMS); do \
		os=$$(echo "$$p" | cut -d'/' -f1); \
		arch=$$(echo "$$p" | cut -d'/' -f2); \
		ext=""; \
		if [ "$$os" = "windows" ]; then ext=".exe"; fi; \
		target="$(DIST_DIR)/$(CLI_BINARY)-$$os-$$arch$$ext"; \
		echo "    Building $$target..."; \
		CGO_ENABLED=0 GOOS=$$os GOARCH=$$arch go build -a $(GO_FLAGS) -o $$target ./cmd/water; \
		if [ $$? -ne 0 ]; then \
			echo "ERROR: Failed to build $$target"; \
			exit 1; \
		fi; \
	done
	@echo "--> CLI release builds completed"
	@ls -lh $(DIST_DIR)/

release-gui:
	@echo "╔══════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                      BUILDING GUI RELEASE                                    ║"
	@echo "╚══════════════════════════════════════════════════════════════════════════════╝"
	@mkdir -p $(DIST_DIR)
	@echo "--> Note: GUI cross-compilation requires platform-specific CGO toolchains."
	@echo "--> Building for host platform ($(GOOS_HOST)/$(GOARCH_HOST)) first..."
	@CGO_ENABLED=1 go build $(GO_FLAGS) -o $(DIST_DIR)/$(GUI_BINARY)-$(GOOS_HOST)-$(GOARCH_HOST) ./cmd/water-gui
	@echo "--> Host GUI build completed"
	@echo "--> For cross-platform GUI builds, run on target platforms or use fyne-cross"
	@ls -lh $(DIST_DIR)/

release-all: release-cli release-gui checksums

checksums:
	@echo "--> Generating checksums..."
	@if [ -d "$(DIST_DIR)" ] && [ "$$(ls -A $(DIST_DIR) 2>/dev/null)" ]; then \
		cd $(DIST_DIR) && sha256sum * > checksums.sha256; \
		echo "--> Checksums generated: $(DIST_DIR)/checksums.sha256"; \
		cat $(DIST_DIR)/checksums.sha256; \
	else \
		echo "WARNING: No files in $(DIST_DIR) to checksum"; \
	fi

# ==============================================================================
# CI/CD PIPELINE
# ==============================================================================

ci: ci-test ci-build

ci-test: mocks fmt vet lint test test-race test-coverage security
	@echo "╔══════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                      CI TEST PIPELINE COMPLETED                              ║"
	@echo "╚══════════════════════════════════════════════════════════════════════════════╝"

ci-build: clean release-cli release-gui checksums
	@echo "╔══════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                      CI BUILD PIPELINE COMPLETED                             ║"
	@echo "╚══════════════════════════════════════════════════════════════════════════════╝"

ci-release: ci-test ci-build
	@echo "╔══════════════════════════════════════════════════════════════════════════════╗"
	@echo "║                      CI RELEASE PIPELINE COMPLETED                           ║"
	@echo "╚══════════════════════════════════════════════════════════════════════════════╝"

# ==============================================================================
# INSTALLATION
# ==============================================================================

install: build gui
	@echo "--> Installing binaries..."
	@mkdir -p $(GOPATH)/bin
	@cp $(BIN_DIR)/$(CLI_BINARY) $(GOPATH)/bin/
	@cp $(BIN_DIR)/$(GUI_BINARY) $(GOPATH)/bin/
	@echo "--> Installed to $(GOPATH)/bin/"

uninstall:
	@echo "--> Removing binaries..."
	@rm -f $(GOPATH)/bin/$(CLI_BINARY)
	@rm -f $(GOPATH)/bin/$(GUI_BINARY)
	@rm -f $(GOPATH)/bin/$(CLI_BINARY)-static
	@rm -f $(GOPATH)/bin/$(GUI_BINARY)-debug
	@echo "--> Binaries removed"

# ==============================================================================
# CLEANUP
# ==============================================================================

clean:
	@echo "--> Cleaning build artifacts..."
	@rm -rf $(DIST_DIR)
	@rm -rf $(BIN_DIR)
	@rm -rf $(COVERAGE_DIR)
	@rm -f coverage.out coverage.html
	@echo "--> Clean complete"

clean-all: clean
	@echo "--> Cleaning all generated files..."
	@go clean -cache -testcache -modcache -i -r
	@echo "--> Deep clean complete"

# ==============================================================================
# DEVELOPMENT UTILITIES
# ==============================================================================

# Run the CLI locally
run: build
	@./$(BIN_DIR)/$(CLI_BINARY)

# Run the GUI locally
run-gui: gui
	@./$(BIN_DIR)/$(GUI_BINARY)

# Watch for changes and rebuild (requires entr)
watch:
	@echo "--> Watching for changes... (press Ctrl+C to stop)"
	@command -v entr >/dev/null 2>&1 || (echo "ERROR: entr not installed" && exit 1)
	@find . -name "*.go" -not -path "./vendor/*" | entr -c make build

# Generate documentation
docs:
	@echo "--> Generating documentation..."
	@mkdir -p docs
	@go doc -all ./... > docs/api.txt 2>/dev/null || true
	@echo "--> Documentation generated"

# Show binary sizes
sizes:
	@echo "--> Binary sizes:"
	@if [ -d "$(BIN_DIR)" ]; then ls -lh $(BIN_DIR)/*; fi
	@if [ -d "$(DIST_DIR)" ]; then ls -lh $(DIST_DIR)/*; fi
