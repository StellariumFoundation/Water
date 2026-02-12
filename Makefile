# ==============================================================================
# WATER AI — UNIFIED BUILD SYSTEM
# ==============================================================================
#
# Produces a SINGLE binary that starts both the gateway/backend service AND
# the Fyne GUI.  CGO_ENABLED=1 is required for Fyne.
#
# Usage:
#   make build              — Build for current platform
#   make build-linux        — Cross-compile for linux/amd64
#   make build-darwin       — Cross-compile for darwin/amd64
#   make build-windows      — Cross-compile for windows/amd64
#   make test               — Run tests with race detection + coverage
#   make release            — Auto-detect OS and build native release artifacts
#   make release-linux      — Build linux .run self-extracting installers
#   make release-darwin     — Build macOS .dmg disk images
#   make release-windows    — Build windows .exe with embedded icon
#   make compress           — UPX-compress binaries in dist/ (optional)
#   make clean              — Remove build artifacts
#   make help               — Show this help
#
# Cross-compilation notes (Fyne / CGO):
#   Linux  → needs gcc, pkg-config, libgl1-mesa-dev, libxcursor-dev, etc.
#   macOS  → needs Xcode Command Line Tools (native) or osxcross (cross)
#   Windows→ needs x86_64-w64-mingw32-gcc (MinGW-w64)
#
# ==============================================================================

# --- Shell -------------------------------------------------------------------
SHELL      := /bin/bash
.SHELLFLAGS := -euo pipefail -c

# --- Project -----------------------------------------------------------------
BINARY     := Water
MODULE     := water-ai
CMD_PKG    := ./cmd/water
APP_ID     := ai.water.app
APP_ICON   := resources/logo-only.png

# --- Version info (injected via ldflags) -------------------------------------
VERSION    ?= v0.2.0
GIT_COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null || echo "unknown")
BUILD_DATE := $(shell date -u +"%Y-%m-%dT%H:%M:%SZ")
GO_VERSION := $(shell go version 2>/dev/null | awk '{print $$3}' || echo "unknown")

# --- Directories -------------------------------------------------------------
DIST_DIR     := dist
BIN_DIR      := bin
COVERAGE_DIR := coverage

# --- Test settings ------------------------------------------------------------
TEST_TIMEOUT := 15m

# --- Host detection ----------------------------------------------------------
UNAME_S := $(shell uname -s 2>/dev/null || echo "Windows_NT")
UNAME_M := $(shell uname -m 2>/dev/null || echo "x86_64")

ifeq ($(UNAME_S),Linux)
    GOOS_HOST := linux
else ifeq ($(UNAME_S),Darwin)
    GOOS_HOST := darwin
else ifneq (,$(findstring MINGW,$(UNAME_S)))
    GOOS_HOST := windows
else ifneq (,$(findstring MSYS,$(UNAME_S)))
    GOOS_HOST := windows
else ifneq (,$(findstring Windows,$(UNAME_S)))
    GOOS_HOST := windows
else
    GOOS_HOST := linux
endif

ifeq ($(filter $(UNAME_M),x86_64 amd64),)
    GOARCH_HOST := arm64
else
    GOARCH_HOST := amd64
endif

# Allow overriding via environment (useful in CI)
ifdef TARGET_OS
    GOOS_HOST := $(TARGET_OS)
endif
ifdef TARGET_ARCH
    GOARCH_HOST := $(TARGET_ARCH)
endif

# --- Build flags (ultra-optimised) -------------------------------------------
LDFLAGS := -s -w \
	-X 'main.Version=$(VERSION)' \
	-X 'main.GitCommit=$(GIT_COMMIT)' \
	-X 'main.BuildDate=$(BUILD_DATE)' \
	-X 'main.GoVersion=$(GO_VERSION)'

# Static linking flags for Linux (self-contained binaries)
LDFLAGS_STATIC := $(LDFLAGS) -extldflags '-static'

GO_BUILD_FLAGS := -trimpath -ldflags "$(LDFLAGS)"
GO_BUILD_FLAGS_STATIC := -trimpath -tags static -ldflags "$(LDFLAGS_STATIC)"

# CGO is required for Fyne
export CGO_ENABLED := 1


# ==============================================================================
# PHONY
# ==============================================================================
.PHONY: all help build build-linux build-darwin build-windows \
        test test-unit test-race test-vet test-lint test-coverage test-short \
        release release-linux release-linux-local release-darwin release-darwin-local \
        release-windows release-windows-local release-local \
        compress checksums \
        clean clean-all \
        deps deps-linux deps-windows deps-update mocks \
        fmt vet lint security \
        version info install run

# --- Default -----------------------------------------------------------------
all: deps test build

# ==============================================================================
# HELP
# ==============================================================================
help:
	@echo "╔══════════════════════════════════════════════════════════════╗"
	@echo "║              WATER AI — UNIFIED BUILD SYSTEM               ║"
	@echo "╠══════════════════════════════════════════════════════════════╣"
	@echo "║  make build            Build for current platform          ║"
	@echo "║  make build-linux      Cross-compile linux/amd64           ║"
	@echo "║  make build-darwin     Cross-compile darwin/amd64          ║"
	@echo "║  make build-windows    Cross-compile windows/amd64         ║"
	@echo "║  make test             Run ALL tests (vet+lint+unit+race) ║"
	@echo "║  make test-unit        Unit tests only                     ║"
	@echo "║  make test-race        Tests with race detection           ║"
	@echo "║  make test-vet         Run go vet                          ║"
	@echo "║  make test-lint        Run linter (if available)           ║"
	@echo "║  make test-coverage    Generate coverage report            ║"
	@echo "║  make test-short       Quick tests (no race)               ║"
	@echo "║  make release          Auto-detect OS & build artifacts    ║"
	@echo "║  make release-linux    Build linux .run installers         ║"
	@echo "║  make release-darwin   Build macOS .dmg disk images        ║"
	@echo "║  make release-windows  Build windows .exe (icon embedded)  ║"
	@echo "║  make compress         UPX-compress dist/ binaries         ║"
	@echo "║  make clean            Remove build artifacts              ║"
	@echo "║  make deps             Download Go dependencies            ║"
	@echo "║  make deps-linux       Install Linux system dependencies  ║"
	@echo "║  make deps-update      Update all dependencies             ║"
	@echo "║  make lint             Run golangci-lint                   ║"
	@echo "║  make version          Print version info                  ║"
	@echo "║  make info             Full build environment info         ║"
	@echo "╚══════════════════════════════════════════════════════════════╝"


# ==============================================================================
# VERSION / INFO
# ==============================================================================
version:
	@echo "Version:    $(VERSION)"
	@echo "Commit:     $(GIT_COMMIT)"
	@echo "Build Date: $(BUILD_DATE)"
	@echo "Go Version: $(GO_VERSION)"

info: version
	@echo "Host OS:    $(GOOS_HOST)"
	@echo "Host Arch:  $(GOARCH_HOST)"
	@echo "CGO:        $(CGO_ENABLED)"

# ==============================================================================
# SYSTEM DEPENDENCIES
# ==============================================================================
deps-linux:
	@echo "--> Installing Linux system dependencies for Fyne..."
	@sudo apt-get update -qq
	@sudo apt-get install -y -qq gcc g++ make pkg-config \
		libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev \
		libx11-dev libxcursor-dev libxrandr-dev \
		libxinerama-dev libxi-dev libxxf86vm-dev \
		libasound2-dev \
		gcc-aarch64-linux-gnu g++-aarch64-linux-gnu \
		makeself
	@echo "--> Installing fyne CLI..."
	@go install fyne.io/fyne/v2/cmd/fyne@latest
	@echo "--> Linux dependencies installed"

deps-linux-static:
	@echo "--> Installing Linux static-linking dependencies for Fyne..."
	@sudo apt-get update -qq
	@sudo apt-get install -y -qq gcc g++ make pkg-config \
		libgl1-mesa-dev libegl1-mesa-dev libgles2-mesa-dev \
		libx11-dev libxcursor-dev libxrandr-dev \
		libxinerama-dev libxi-dev libxxf86vm-dev \
		libasound2-dev \
		libgl-dev libx11-xcb-dev libxkbcommon-dev \
		libwayland-dev libvulkan-dev \
		gcc-aarch64-linux-gnu g++-aarch64-linux-gnu
	@echo "--> Linux static dependencies installed"

deps-windows:
	@echo "--> Installing Windows (MSYS2) dependencies for Fyne..."
	pacman --noconfirm -S mingw-w64-x86_64-toolchain mingw-w64-x86_64-pkg-config || true
	@echo "--> Windows dependencies installed"
deps-darwin:
	@echo "--> macOS dependencies (Xcode CLT assumed)..."
	@echo "--> Installing fyne CLI..."
	@go install fyne.io/fyne/v2/cmd/fyne@latest
	@echo "--> macOS dependencies ready"

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

mocks:
	@mkdir -p browser/embed
	@touch browser/embed/OpenSans-Medium.ttf
	@touch browser/embed/findVisibleInteractiveElements.js

# ==============================================================================
# CODE QUALITY
# ==============================================================================
fmt:
	@go fmt ./...

vet:
	@go vet ./...

lint:
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run --timeout 5m ./...; \
	else \
		echo "WARN: golangci-lint not installed — skipping"; \
	fi

security:
	@if command -v govulncheck >/dev/null 2>&1; then \
		govulncheck ./...; \
	else \
		echo "WARN: govulncheck not installed — skipping"; \
	fi

# ==============================================================================
# TESTING
# ==============================================================================

# Top-level test target — runs ALL test sub-targets
test: test-vet test-lint test-unit test-race
	@echo "--> All tests passed"

test-unit: mocks
	@echo "--> Running unit tests..."
	@CGO_ENABLED=1 go test -v -count=1 -timeout $(TEST_TIMEOUT) ./...
	@echo "--> Unit tests passed"

test-race: mocks
	@echo "--> Running tests with race detection..."
	@CGO_ENABLED=1 go test -race -v -count=1 -timeout $(TEST_TIMEOUT) ./...
	@echo "--> Race detection tests passed"

test-vet:
	@echo "--> Running go vet..."
	@go vet ./...
	@echo "--> go vet passed"

test-lint:
	@echo "--> Running lint checks..."
	@if command -v golangci-lint >/dev/null 2>&1; then \
		golangci-lint run --timeout 5m ./...; \
	elif command -v staticcheck >/dev/null 2>&1; then \
		staticcheck ./...; \
	else \
		echo "WARN: golangci-lint/staticcheck not installed — skipping lint"; \
	fi
	@echo "--> Lint checks passed"

test-coverage: mocks
	@echo "--> Generating coverage report..."
	@mkdir -p $(COVERAGE_DIR)
	@PKGS=$$(CGO_ENABLED=1 go list ./... | xargs -I{} sh -c 'go list -f "{{if .TestGoFiles}}{{.ImportPath}}{{end}}" {} 2>/dev/null' | grep -v '^$$'); \
	if [ -n "$$PKGS" ]; then \
		CGO_ENABLED=1 go test -coverprofile=$(COVERAGE_DIR)/coverage.out -covermode=atomic -count=1 -timeout $(TEST_TIMEOUT) $$PKGS || true; \
		if [ -f $(COVERAGE_DIR)/coverage.out ]; then \
			go tool cover -func=$(COVERAGE_DIR)/coverage.out | tail -n 1; \
		fi; \
	else \
		echo "WARN: no packages with test files found"; \
	fi
	@echo "--> Coverage report: $(COVERAGE_DIR)/coverage.out"

test-short: mocks
	@echo "--> Running short tests..."
	@go test -short -v -count=1 -timeout 5m ./...
	@echo "--> Short tests passed"

# ==============================================================================
# BUILD — single unified binary (gateway + GUI)
# ==============================================================================
build:
	@echo "--> Building $(BINARY) for $(GOOS_HOST)/$(GOARCH_HOST)..."
	@mkdir -p $(BIN_DIR)
	@CGO_ENABLED=1 go build $(GO_BUILD_FLAGS) -o $(BIN_DIR)/$(BINARY) $(CMD_PKG)
	@echo "--> $(BIN_DIR)/$(BINARY)"

build-linux:
	@echo "--> Building $(BINARY) for linux/amd64..."
	@mkdir -p $(BIN_DIR)
	@GOOS=linux GOARCH=amd64 CGO_ENABLED=1 go build $(GO_BUILD_FLAGS) \
		-o $(BIN_DIR)/$(BINARY)-linux-amd64 $(CMD_PKG)
	@echo "--> $(BIN_DIR)/$(BINARY)-linux-amd64"

build-darwin:
	@echo "--> Building $(BINARY) for darwin/amd64..."
	@mkdir -p $(BIN_DIR)
	@GOOS=darwin GOARCH=amd64 CGO_ENABLED=1 go build $(GO_BUILD_FLAGS) \
		-o $(BIN_DIR)/$(BINARY)-darwin-amd64 $(CMD_PKG)
	@echo "--> $(BIN_DIR)/$(BINARY)-darwin-amd64"

build-windows:
	@echo "--> Building $(BINARY) for windows/amd64..."
	@mkdir -p $(BIN_DIR)
	@GOOS=windows GOARCH=amd64 CGO_ENABLED=1 CC=x86_64-w64-mingw32-gcc \
		go build $(GO_BUILD_FLAGS) -o $(BIN_DIR)/$(BINARY)-windows-amd64.exe $(CMD_PKG)
	@echo "--> $(BIN_DIR)/$(BINARY)-windows-amd64.exe"

# Build Go backend only (no Node.js/frontend required)
build-dev: mocks
	@echo "--> Building Go backend (dev mode, no frontend)..."
	@mkdir -p $(BIN_DIR)
	@CGO_ENABLED=0 go build $(GO_FLAGS) -o $(BIN_DIR)/$(BINARY_NAME) ./cmd/water
	@echo "Done! Run with: ./$(BIN_DIR)/$(BINARY_NAME)"

# ==============================================================================
# RELEASE — auto-detect OS and call the appropriate platform target
# ==============================================================================
# Each platform target installs its own dependencies, then builds both amd64
# and arm64 binaries natively (no cross-compilation across OS boundaries).
# CI matrix runners each call `make release` which auto-dispatches.
# ==============================================================================

release: clean
	@echo "╔══════════════════════════════════════════════════════════════╗"
	@echo "║           BUILDING RELEASE BINARIES                        ║"
	@echo "╚══════════════════════════════════════════════════════════════╝"
ifeq ($(GOOS_HOST),linux)
	@$(MAKE) release-linux
else ifeq ($(GOOS_HOST),darwin)
	@$(MAKE) release-darwin
else
	@$(MAKE) release-windows
endif
	@$(MAKE) checksums
	@echo "--> Release builds in $(DIST_DIR)/"
	@ls -lh $(DIST_DIR)/

# ------------------------------------------------------------------------------
# release-linux — statically linked self-contained binaries
# ------------------------------------------------------------------------------
release-linux: deps-linux-static
	@echo "--> Building Linux release binaries (statically linked)..."
	@mkdir -p $(DIST_DIR)
	@echo "    Building $(DIST_DIR)/$(BINARY)-linux-amd64 (static)..."
	@CGO_ENABLED=1 GOOS=linux GOARCH=amd64 \
		go build -a $(GO_BUILD_FLAGS_STATIC) -o $(DIST_DIR)/$(BINARY)-linux-amd64 $(CMD_PKG)
	@echo "    Building $(DIST_DIR)/$(BINARY)-linux-arm64 (static)..."
	@CGO_ENABLED=1 GOOS=linux GOARCH=arm64 CC=aarch64-linux-gnu-gcc \
		go build -a $(GO_BUILD_FLAGS_STATIC) -o $(DIST_DIR)/$(BINARY)-linux-arm64 $(CMD_PKG)
	@echo "--> Linux release binaries built (statically linked)"

# ------------------------------------------------------------------------------
# release-darwin — .app bundles via fyne package (self-contained)
# ------------------------------------------------------------------------------
release-darwin: deps-darwin
	@echo "--> Building macOS release .app bundles..."
	@mkdir -p $(DIST_DIR)
	@echo "    Building $(BINARY)-darwin-amd64.app ..."
	@CGO_ENABLED=1 GOOS=darwin GOARCH=amd64 \
		fyne package -os darwin -name $(BINARY) -appID ai.water.app \
		-icon resources/logo-only.png -src $(CMD_PKG) \
		-release
	@mv $(BINARY).app $(DIST_DIR)/$(BINARY)-darwin-amd64.app || true
	@cd $(DIST_DIR) && zip -r $(BINARY)-darwin-amd64.zip $(BINARY)-darwin-amd64.app && rm -rf $(BINARY)-darwin-amd64.app
	@echo "    Building $(BINARY)-darwin-arm64.app ..."
	@CGO_ENABLED=1 GOOS=darwin GOARCH=arm64 \
		fyne package -os darwin -name $(BINARY) -appID ai.water.app \
		-icon resources/logo-only.png -src $(CMD_PKG) \
		-release
	@mv $(BINARY).app $(DIST_DIR)/$(BINARY)-darwin-arm64.app || true
	@cd $(DIST_DIR) && zip -r $(BINARY)-darwin-arm64.zip $(BINARY)-darwin-arm64.app && rm -rf $(BINARY)-darwin-arm64.app
	@echo "--> macOS release .app bundles built"

# ------------------------------------------------------------------------------
# release-windows — .exe with embedded manifest/icon via fyne package
# ------------------------------------------------------------------------------
release-windows: deps-windows
	@echo "--> Building Windows release binaries (fyne package)..."
	@mkdir -p $(DIST_DIR)
	@echo "    Building $(BINARY)-windows-amd64.exe ..."
	@CGO_ENABLED=1 GOOS=windows GOARCH=amd64 \
		fyne package -os windows -name $(BINARY) -appID ai.water.app \
		-icon resources/logo-only.png -src $(CMD_PKG) \
		-release
	@mv $(BINARY).exe $(DIST_DIR)/$(BINARY)-windows-amd64.exe || true
	@echo "    Building $(BINARY)-windows-arm64.exe ..."
	@CGO_ENABLED=1 GOOS=windows GOARCH=arm64 \
		fyne package -os windows -name $(BINARY) -appID ai.water.app \
		-icon resources/logo-only.png -src $(CMD_PKG) \
		-release
	@mv $(BINARY).exe $(DIST_DIR)/$(BINARY)-windows-arm64.exe || true
	@echo "--> Windows release binaries built"

# ------------------------------------------------------------------------------
# release-windows-local — build a single .exe for the current arch only (CI use)
# ------------------------------------------------------------------------------
release-windows-local:
	@echo "--> Building Windows .exe for $(GOARCH_HOST) with embedded icon..."
	@mkdir -p $(DIST_DIR)
	@CGO_ENABLED=1 GOOS=windows GOARCH=$(GOARCH_HOST) \
		fyne package -os windows -icon $(APP_ICON) -appID $(APP_ID) \
		-name $(BINARY) -src $(CMD_PKG) -release
	@mv $(BINARY).exe $(DIST_DIR)/$(BINARY)-windows-$(GOARCH_HOST).exe
	@echo "--> $(DIST_DIR)/$(BINARY)-windows-$(GOARCH_HOST).exe"

# ------------------------------------------------------------------------------
# release-local — build a single release artifact for the current platform
# ------------------------------------------------------------------------------
# Dispatches to the platform-specific -local target which produces the proper
# artifact format (.dmg, .run, .exe with icon).
release-local:
	@echo "╔══════════════════════════════════════════════════════════════╗"
	@echo "║       BUILDING RELEASE ARTIFACT (native platform)          ║"
	@echo "╚══════════════════════════════════════════════════════════════╝"
	@mkdir -p $(DIST_DIR)
	$(eval _OS   := $(or $(GOOS),$(GOOS_HOST)))
	$(eval _ARCH := $(or $(GOARCH),$(GOARCH_HOST)))
	$(eval _EXT  := $(if $(filter windows,$(_OS)),.exe,))
	$(eval _OUT  := $(DIST_DIR)/$(BINARY)-$(_OS)-$(_ARCH)$(_EXT))
	@echo "    Building $(_OUT) ..."
ifeq ($(GOOS_HOST),linux)
	@echo "    (using static linking for Linux)"
	@CGO_ENABLED=1 GOOS=$(_OS) GOARCH=$(_ARCH) \
		go build -a $(GO_BUILD_FLAGS_STATIC) -o $(_OUT) $(CMD_PKG)
else ifeq ($(GOOS_HOST),darwin)
	@echo "    (using fyne package for macOS .app bundle)"
	@CGO_ENABLED=1 GOOS=$(_OS) GOARCH=$(_ARCH) \
		fyne package -os darwin -name $(BINARY) -appID ai.water.app \
		-icon resources/logo-only.png -src $(CMD_PKG) -release
	@mv $(BINARY).app $(DIST_DIR)/$(BINARY)-$(_OS)-$(_ARCH).app || true
	@cd $(DIST_DIR) && zip -r $(BINARY)-$(_OS)-$(_ARCH).zip $(BINARY)-$(_OS)-$(_ARCH).app && rm -rf $(BINARY)-$(_OS)-$(_ARCH).app
else
	@echo "    (using fyne package for Windows .exe)"
	@CGO_ENABLED=1 GOOS=$(_OS) GOARCH=$(_ARCH) \
		fyne package -os windows -name $(BINARY) -appID ai.water.app \
		-icon resources/logo-only.png -src $(CMD_PKG) -release
	@mv $(BINARY).exe $(_OUT) || true
endif
	@echo "--> $(_OUT)"

checksums:
	@if [ -d "$(DIST_DIR)" ] && [ "$$(ls -A $(DIST_DIR) 2>/dev/null)" ]; then \
		cd $(DIST_DIR) && \
		if command -v sha256sum >/dev/null 2>&1; then \
			sha256sum * > checksums.sha256; \
		elif command -v shasum >/dev/null 2>&1; then \
			shasum -a 256 * > checksums.sha256; \
		else \
			echo "WARN: no sha256sum or shasum found — skipping checksums"; \
		fi; \
		echo "--> $(DIST_DIR)/checksums.sha256"; \
	fi

# ==============================================================================
# COMPRESS (optional — requires UPX)
# ==============================================================================
compress:
	@if command -v upx >/dev/null 2>&1; then \
		echo "--> Compressing binaries with UPX..."; \
		for f in $(DIST_DIR)/$(BINARY)-*; do \
			upx --best --lzma "$$f" 2>/dev/null || true; \
		done; \
		echo "--> Compression complete"; \
	else \
		echo "WARN: UPX not found — skipping compression"; \
	fi

# ==============================================================================
# INSTALL / RUN
# ==============================================================================
install: build
	@echo "--> Installing $(BINARY) to $(GOPATH)/bin/"
	@mkdir -p $(GOPATH)/bin
	@cp $(BIN_DIR)/$(BINARY) $(GOPATH)/bin/
	@echo "--> Installed"

run: build
	@./$(BIN_DIR)/$(BINARY)

# ==============================================================================
# CLEAN
# ==============================================================================
clean:
	@echo "--> Cleaning build artifacts..."
	@rm -rf $(DIST_DIR) $(BIN_DIR) $(COVERAGE_DIR)
	@rm -f coverage.out coverage.html
	@echo "--> Clean"

clean-all: clean
	@go clean -cache -testcache -modcache -i -r 2>/dev/null || true
	@echo "--> Deep clean complete"
