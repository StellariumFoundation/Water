<p align="center">
  <img src="resources/logo.png" alt="Water AI Logo" width="200"/>
</p>

<h1 align="center">🌊 Water AI: An AI Supermodel</h1>

<p align="center">
  <em>"You put water into a cup, it becomes the cup. You put water into a bottle, it becomes the bottle. Be water, my friend."</em> — <strong>Bruce Lee</strong>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache_2.0-blue.svg" alt="License"></a>
  <a href="https://goreportcard.com/report/github.com/StellariumFoundation/Water"><img src="https://goreportcard.com/badge/github.com/StellariumFoundation/Water" alt="Go Report Card"></a>
  <a href="ROADMAP.md"><img src="https://img.shields.io/badge/Phase-1_MVP-cyan" alt="Version"></a>
  <a href="https://golang.org/dl/"><img src="https://img.shields.io/badge/Go-1.24+-00ADD8?logo=go&logoColor=white" alt="Go Version"></a>
</p>

---

## 📖 Overview

**Water AI** is the intelligent core of the Water ecosystem — the most ambitious project in the Stellarium suite. Conceived by **John Victor**, it is designed not merely as a tool, but as a practical and accessible form of **Artificial General Intelligence (AGI)** that serves as a universal force-multiplier for human potential. It is a gift to humanity and a cornerstone technology for achieving the **"Elevation to Eden."**

Water AI is an **AI Supermodel** that intelligently aggregates the world's best specialized AI capabilities and action-taking prowess into a single, accessible platform. It understands complex requests, routes them to state-of-the-art specialized AI models (finance, law, engineering, creative arts, and more), and then **acts** — drafting contracts, generating 3D designs, composing strategies, coding software, and launching campaigns.

---

## 💎 Vision: Augmenting Humanity

**The Problem:** The AI revolution is here, yet its power remains fragmented. Users navigate a complex ecosystem of specialized tools, while general AI models lack deep expertise in every domain. This limits true human augmentation.

**The Solution:** Water AI solves this by acting as the **Master Orchestrator**. It provides a single, fluid interface that understands complex intent, decomposes tasks, routes them to the best-in-class specialized models, and performs actual digital labor — all while maintaining context and enabling human-AI collaboration.

---

## 🚀 Key Differentiators

| Differentiator | Description |
|---|---|
| **Best-of-Kind Specialization** | Dynamically leverages a curated ecosystem of the world's leading specialized AIs across finance, law, engineering, creative arts, and more. |
| **True Action & Labor Performing** | Goes beyond text generation — creates, builds, and executes across digital tasks including document creation, code generation, web interaction, and data manipulation. |
| **Open, Accessible & Client-Run** | Open-source core components with the ability to run on client devices via WebAssembly for data sovereignty and privacy. |
| **Intelligent Orchestration** | Sophisticated Go-based AI core for planning, tool selection, task decomposition, multi-model routing, and human-AI collaboration. |
| **Formless & Persistent** | Runs as a background daemon on your OS, accessible via a native desktop GUI, web interface, or remote bridges. |

---

## 🎯 Target Users

- **Professionals** — Legal, Finance, Healthcare, Engineering, Business
- **Creatives** — Designers, Writers, Artists, Developers
- **Researchers & Academics** — Deep research, fact-checking, data analysis
- **Students & Lifelong Learners** — Learning augmentation and knowledge synthesis
- **General Knowledge Workers & Individuals** — Everyday productivity and task automation

---

## ✨ Features

### Intuitive Multi-Modal Interface
- Chat interface supporting text, file uploads, and voice input
- Downloadable native desktop client (Windows, macOS, Linux) built with [Fyne](https://fyne.io/)
- Web access via embedded frontend
- Multi-format output with user control and iteration

### Intelligent Orchestration Engine
- Intent understanding and task decomposition
- Multi-model routing to specialized AIs
- Context management with token-aware windowing
- Response synthesis across multiple model outputs
- Sequential thinking and planning modules

### Specialized AI Model Ecosystem
- Curated models from Hugging Face, open-source, and commercial sources
- Multi-provider LLM support (OpenAI, Anthropic, Google Gemini)
- Domain-specific routing for finance, law, engineering, creative arts, and more

### Action & Labor Performing Engine
- **Document Creation** — Drafting contracts, reports, presentations
- **Code Generation & Execution** — Write, run, and debug software in sandboxed environments
- **Web Interaction** — Browser automation via Playwright for research and data gathering
- **Data Manipulation** — Processing, analysis, and visualization
- **Creative Generation** — Image generation, audio transcription, media processing
- Client-side (WebAssembly/Python) and cloud-side execution paths

### Integration Framework
- Web search (Tavily, Jina, SerpAPI, DuckDuckGo)
- Third-party API integrations (Vercel, NeonDB, cloud storage)
- Email, social media, and web service connectors (planned)

---

## 🏗 Technical Architecture

```
Water AI Architecture
┌─────────────────────────────────────────────────────────┐
│                    CLIENT LAYER                          │
│  ┌──────────┐  ┌──────────────┐  ┌───────────────────┐  │
│  │ Fyne GUI │  │ Web Frontend │  │ WebAssembly (WASM) │  │
│  └────┬─────┘  └──────┬───────┘  └────────┬──────────┘  │
│       └───────────┬────┘                   │             │
│              WebSocket / HTTP              │             │
└──────────────────┬─────────────────────────┘             │
                   │                                       │
┌──────────────────▼───────────────────────────────────────┐
│                   SERVER LAYER                            │
│  ┌─────────────────────────────────────────────────────┐ │
│  │           Gateway (Gin HTTP/WS Server)              │ │
│  │  • Session Management  • File Upload  • Health API  │ │
│  └────────────────────┬────────────────────────────────┘ │
│                       │                                  │
│  ┌────────────────────▼────────────────────────────────┐ │
│  │          Orchestration Engine (Agents)               │ │
│  │  • Prompt Builder  • Context Manager  • Reviewer    │ │
│  │  • Task Decomposition  • Tool Selection             │ │
│  └────────────────────┬────────────────────────────────┘ │
│                       │                                  │
│  ┌────────────────────▼────────────────────────────────┐ │
│  │              Tool & Action Layer                     │ │
│  │  • Browser  • Terminal  • File Editor  • Search     │ │
│  │  • Media    • Code Exec • Web Scraping              │ │
│  └────────────────────┬────────────────────────────────┘ │
│                       │                                  │
│  ┌────────────────────▼────────────────────────────────┐ │
│  │           LLM Provider Layer                        │ │
│  │  • OpenAI  • Anthropic  • Google Gemini             │ │
│  └─────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌─────────────────────────────────────────────────────┐ │
│  │  Infrastructure: SQLite/GORM • Sandbox (Docker/E2B) │ │
│  │  Config • Logging • Migrations • Process Manager    │ │
│  └─────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────┘
```

**Privacy by Design:** Minimal data retention with client-side execution options. Envisioned to run high-performance actions locally on client devices to ensure data sovereignty.

---

## 📁 Project Structure

```
Water/
├── cmd/water/              # Main entry point (daemon + Fyne GUI launcher)
├── server/                 # HTTP/WebSocket server (Gin-based)
├── agents/                 # AI agent abstractions (Base, Reviewer, FunctionCall)
├── browser/                # Headless browser automation (Playwright)
├── core/                   # Core utilities: logging, config, event system, storage
├── db/                     # Database layer (SQLite via GORM)
├── llm/                    # LLM clients (Anthropic, Gemini, OpenAI)
│   └── context_manager/    # Token counting and context window management
├── migrations/             # Database migrations (Goose)
├── process/                # Process/session management & gateway
├── prompts/                # System prompt builder with domain-specific rules
├── sandbox/                # Sandboxed execution (Docker, E2B, Local)
├── tools/                  # Tool implementations (browser, terminal, search, media, etc.)
├── ui/                     # Fyne desktop GUI (chat, panels, settings, theme)
├── utils/                  # Shared utilities (file manager, terminal manager)
├── resources/              # Logo and static assets
├── plans/                  # Architecture and planning documents
├── .github/                # CI/CD workflows (GitHub Actions)
├── Makefile                # Unified build system
└── ROADMAP.md              # Detailed feature roadmap
```

---

## 🛠 Getting Started

### Prerequisites

- [Go 1.24+](https://golang.org/dl/)
- GCC / Clang (CGO is required for the Fyne GUI)
  - **Linux:** `libgl1-mesa-dev`, `libxcursor-dev`, `libxrandr-dev`, `libxinerama-dev`, `libxi-dev`, `libxxf86vm-dev`
  - **macOS:** Xcode Command Line Tools
  - **Windows:** MinGW-w64

### Quick Start (Development)

```bash
git clone https://github.com/StellariumFoundation/Water.git
cd Water

# Build the Go binary (no frontend/Node.js required)
make build-dev

# Run the server in headless mode
./bin/water-ai server
```

The server starts on `http://localhost:7777`.

### Full Build (with GUI)

```bash
# Build the complete application with Fyne GUI
make build

# Run — launches gateway + native desktop GUI
./bin/Water

# Or run headless server only
./bin/Water server

# Check version
./bin/Water --version
```

### Running Tests

```bash
make test              # Run all unit tests
make test-race         # Run tests with race detection
make test-coverage     # Generate HTML coverage report
```

### Cross-Platform Release

```bash
make release           # Build optimized binaries for all platforms
```

Release binaries are output to the `dist/` directory (Linux, macOS, Windows — amd64 + arm64).

---

## 🗺 Roadmap

See [**ROADMAP.md**](ROADMAP.md) for the detailed, feature-level roadmap with implementation status.

### Phase 1: The Drop (MVP) — *In Progress*
- Core platform, multi-LLM orchestration, desktop GUI, tool framework

### Phase 2: The Stream (Expansion)
- Public API, 500+ specialized model integrations, MCP marketplace

### Phase 3: The Ocean (Global Scale)
- Community-driven marketplace, autonomous "Eden" workflows, full AGI capabilities

---

## 🔓 Open Source Strategy

Water AI's core components are **open-source** under the Apache 2.0 License. This strategy ensures:

- **Transparency** — Full visibility into how the AI operates
- **Trust** — Community-auditable codebase
- **Community Contribution** — Developers worldwide can contribute and extend
- **Rapid Adoption** — No barriers to entry for individuals and organizations

---

## 💰 Business Model

| Revenue Stream | Description |
|---|---|
| **Community Support** | Voluntary donations from individuals and organizations |
| **Enterprise Solutions** | Volume licensing and tailored services for businesses |
| **Usage-Based Options** | Fair pricing based on inference and cloud compute consumption |

---

## 💵 Funding

**Funding Ask:** **$600,000** for core platform development, foundational model integration, and key engineering talent.

Funds will be allocated toward:
- Core orchestration engine development
- Foundational specialized model integrations
- Key engineering talent acquisition
- Infrastructure and cloud compute for development and testing

---

## 🤝 Contributing

Water AI is an open-source project fostered by the **Stellarium Foundation**. We welcome developers who share the vision of human augmentation.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/AmazingAction`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

## 🏛 The Foundation

| | |
|---|---|
| **Visionary** | John Victor |
| **Organization** | Stellarium Foundation |
| **Mission** | Leverage technology for global prosperity and human advancement |
| **Goal** | The Elevation to Eden |

---

## 📄 License

This project is licensed under the **Apache 2.0 License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center"><em>"Be water. Flow into the future."</em></p>
