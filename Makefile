# ==============================================================================
# WATER AI - BUILD CONFIGURATION
# ==============================================================================

BINARY_NAME := water-ai
GUI_BINARY  := water-gui
VERSION     := v0.1.1

# Directories
DIST_DIR := dist
BIN_DIR  := bin

# Go Build Flags
LDFLAGS  := -s -w -X 'main.Version=$(VERSION)' -extldflags "-static"
GO_FLAGS := -trimpath -ldflags "$(LDFLAGS)"

# Platforms to build for (OS/ARCH)
PLATFORMS := linux/amd64 linux/arm64 darwin/amd64 darwin/arm64 windows/amd64 windows/arm64

.PHONY: all build clean release test test-race test-coverage help mocks gui gui-release

# Default target
all: clean test release gui

# Help: List available commands
help:
	@echo "Water AI Makefile"
	@echo "-----------------"
	@echo "make all           - Clean, test, and build all binaries"
	@echo "make build         - Build CLI binary for current OS (fast dev build)"
	@echo "make release       - Build optimized CLI binaries for all platforms"
	@echo "make gui           - Build Fyne GUI for current OS"
	@echo "make gui-release   - Build Fyne GUI for all platforms"
	@echo "make test          - Run standard unit tests"
	@echo "make test-race     - Run tests with race detection"
	@echo "make test-coverage - Run tests and generate HTML coverage report"
	@echo "make clean         - Remove build artifacts"

# ==============================================================================
# TESTING
# ==============================================================================

mocks:
	@echo "--> Creating dummy assets for testing..."
	@mkdir -p browser/embed
	@touch browser/embed/OpenSans-Medium.ttf
	@touch browser/embed/findVisibleInteractiveElements.js

test: mocks
	@echo "--> Running Go dependencies check..."
	@go mod tidy
	@echo "--> Running static analysis (go vet)..."
	@go vet ./...
	@echo "--> Running unit tests..."
	@go test ./... -v -count=1

test-race: mocks
	@echo "--> Running tests with race detector..."
	@CGO_ENABLED=1 go test ./... -race -v -count=1

test-coverage: mocks
	@echo "--> Running tests with coverage..."
	@go test ./... -coverprofile=coverage.out -count=1
	@if command -v go >/dev/null 2>&1; then \
		go tool cover -html=coverage.out -o coverage.html; \
		echo "Coverage report generated: coverage.html"; \
	else \
		echo "Coverage report: coverage.out"; \
	fi

# ==============================================================================
# BACKEND BUILD (LOCAL)
# ==============================================================================

build:
	@echo "--> Building local CLI binary..."
	@mkdir -p $(BIN_DIR)
	@CGO_ENABLED=0 go build $(GO_FLAGS) -o $(BIN_DIR)/$(BINARY_NAME) ./cmd/water
	@echo "Done! Run with: ./$(BIN_DIR)/$(BINARY_NAME)"

# ==============================================================================
# RELEASE BUILD (CROSS-PLATFORM)
# ==============================================================================

release:
	@echo "--> Building optimized binaries for platforms: $(PLATFORMS)"
	@mkdir -p $(DIST_DIR)
	@for p in $(PLATFORMS); do \
		os=$$(echo "$$p" | cut -d'/' -f1); \
		arch=$$(echo "$$p" | cut -d'/' -f2); \
		ext=""; \
		if [ "$$os" = "windows" ]; then ext=".exe"; fi; \
		target="$(DIST_DIR)/$(BINARY_NAME)-$$os-$$arch$$ext"; \
		echo "    Building $$target ..."; \
		CGO_ENABLED=0 GOOS=$$os GOARCH=$$arch go build -a $(GO_FLAGS) -o $$target ./cmd/water; \
	done
	@echo "--> Release builds completed in $(DIST_DIR)/"
	@ls -lh $(DIST_DIR)/

# ==============================================================================
# FYNE GUI BUILD
# ==============================================================================

gui:
	@echo "--> Building Fyne GUI for current OS..."
	@mkdir -p $(BIN_DIR)
	@CGO_ENABLED=1 go build $(GO_FLAGS) -o $(BIN_DIR)/$(GUI_BINARY) ./cmd/water-gui
	@echo "Done! Run with: ./$(BIN_DIR)/$(GUI_BINARY)"

gui-release:
	@echo "--> Building Fyne GUI for all platforms..."
	@mkdir -p $(DIST_DIR)
	@echo "    Note: Fyne requires CGO and platform-specific dependencies."
	@echo "    For cross-compilation, use fyne-cross tool."
	@echo ""
	@echo "    Installing fyne-cross if needed..."
	@command -v fyne-cross || go install github.com/fyne-io/fyne-cross@latest
	@echo ""
	@for p in $(PLATFORMS); do \
		os=$$(echo "$$p" | cut -d'/' -f1); \
		arch=$$(echo "$$p" | cut -d'/' -f2); \
		ext=""; \
		if [ "$$os" = "windows" ]; then ext=".exe"; fi; \
		target="$(GUI_BINARY)-$$os-$$arch$$ext"; \
		echo "    Building $$target ..."; \
		fyne-cross $$os -arch $$arch -app-id com.waterai.gui -name $(GUI_BINARY) -output $(DIST_DIR) ./cmd/water-gui; \
	done
	@echo "--> GUI release builds completed in $(DIST_DIR)/"
	@ls -lh $(DIST_DIR)/

# ==============================================================================
# CLEANUP
# ==============================================================================

clean:
	@echo "--> Cleaning up..."
	@rm -rf $(DIST_DIR)
	@rm -rf $(BIN_DIR)
	@rm -f coverage.out coverage.html
	@echo "Clean complete."
