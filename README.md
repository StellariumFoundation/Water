<p align="center">
  <img src="resources/logo.png" alt="Water AI Logo" width="200"/>
</p>

<h1 align="center">🌊 Water AI: The AI Supermodel</h1>

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

## 💎 Vision

**Water AI** is the unified **AI Supermodel** — the intelligent brain of the Water ecosystem and the most ambitious project in the Stellarium suite. Conceived by **John Victor**, founder of the **Stellarium Foundation**, Water AI is designed not merely as a tool, but as a practical and accessible form of **Artificial General Intelligence (AGI)** that serves as a universal force-multiplier for human potential.

It is a **gift to humanity** and a cornerstone technology for achieving the **"Elevation to Eden"** — the Stellarium Foundation's vision for leveraging technology to uplift every person on the planet.

Water AI intelligently aggregates the world's best specialized AI capabilities and action-taking prowess into a single, accessible platform. It understands complex requests, routes them to state-of-the-art specialized AI models, and then **acts** — drafting contracts, generating 3D designs, composing strategies, coding software, and launching campaigns.

---

## 🔴 The Problem

The AI revolution is here, yet its power remains **fragmented**. Users navigate a complex, disconnected ecosystem of specialized tools — one for writing, another for code, another for images, yet another for data analysis. Meanwhile, general-purpose AI models lack deep expertise in every domain.

This fragmentation **limits true human augmentation**. The untapped potential of billions of people remains locked behind technical barriers, subscription fatigue, and the cognitive overhead of juggling dozens of AI tools. The promise of AI as a great equalizer remains unfulfilled.

---

## 💡 The Solution

Water AI solves this by acting as the **Master Orchestrator**. It provides a single, fluid interface that:

- **Understands complex intent** — parses nuanced, multi-part requests
- **Decomposes tasks** — breaks complex goals into actionable sub-tasks
- **Routes intelligently** — sends each sub-task to the best-in-class specialized AI model (finance, law, engineering, creative arts, and more)
- **Performs actual digital labor** — drafts contracts, generates 3D designs, codes software, creates presentations, launches campaigns
- **Maintains context** — remembers conversation history and synthesizes results across multiple model outputs
- **Enables human-AI collaboration** — keeps humans in the loop for critical decisions

---

## 🚀 Key Differentiators

| # | Differentiator | Description |
|---|---|---|
| 1 | **Best-of-Kind Specialization** | Dynamically leverages a curated ecosystem of the world's leading specialized AIs. Instead of one model trying to do everything, Water AI routes to domain experts — finance models for financial analysis, legal models for contract review, creative models for design work. |
| 2 | **True Action & Labor Performing** | Goes far beyond text generation. Water AI actually **does work** — creates documents, generates and executes code, automates browser interactions, manipulates data, generates images, and orchestrates multi-step workflows. |
| 3 | **Open, Accessible & Client-Run** | Open-source core components under Apache 2.0. Designed to run on client devices via **WebAssembly** for data sovereignty and privacy. No vendor lock-in, no barriers to entry. |
| 4 | **Intelligent Orchestration** | Sophisticated Go-based AI core with planning, tool selection, task decomposition, multi-model routing, clarification requests, and human-AI collaboration — not just a simple API wrapper. |

---

## 🎯 Target Users

- **Professionals** — Legal, Finance, Healthcare, Engineering, Business strategists who need domain-expert AI assistance
- **Creatives** — Designers, Writers, Artists, Musicians, and Developers who want AI that creates alongside them
- **Researchers & Academics** — Deep research, fact-checking, data analysis, literature review, and knowledge synthesis
- **Students & Lifelong Learners** — Learning augmentation, tutoring, study aids, and knowledge exploration
- **General Knowledge Workers** — Everyday productivity, task automation, email drafting, scheduling, and information management

---

## ✨ Product Features

### 💬 Chat UI (Multi-Modal Interface)
- Chat interface supporting **text, file uploads, and voice input**
- Rich message rendering with markdown, code blocks, and images
- Slash command system (`/help`, `/compact`)
- Multi-format output with user control and iteration

### 🖥 Downloadable Desktop Client
- Native desktop application for **Windows, macOS, and Linux** built with [Fyne](https://fyne.io/)
- Web access via embedded frontend
- Runs as a background daemon on your OS — always available
- Custom Water AI theme with branding

### 🧠 Orchestration Engine
- Intent understanding and task decomposition
- Multi-model routing to specialized AIs
- Context management with token-aware windowing and conversation summarization
- Response synthesis across multiple model outputs
- Sequential thinking and planning modules
- Reviewer agent for quality assurance and failure detection
- Tool call integrity validation

### 🤖 Specialized Model Ecosystem
- Curated models from **Hugging Face**, open-source, and commercial sources
- Multi-provider LLM support: **OpenAI, Anthropic (Claude), Google Gemini**
- Chain-of-thought model support (o1/o3 models)
- Domain-specific routing for finance, law, engineering, creative arts, and more
- Configurable temperature, max retries, and token limits

### ⚡ Action Engine (Labor Performing)
- **Document Creation** — Drafting contracts, reports, presentations
- **Code Generation & Execution** — Write, run, and debug software in sandboxed environments (Docker, E2B, Local)
- **Web Interaction** — Browser automation via Playwright for research and data gathering
- **Data Manipulation** — Processing, analysis, and visualization
- **Creative Generation** — Image generation (DALL-E), audio transcription (Whisper), media processing
- **Client-side execution** via WebAssembly/Python and cloud-side execution paths

### 🔗 Integration Framework
- **Web Search**: Tavily, Jina, SerpAPI, DuckDuckGo
- **Web Scraping**: Firecrawl integration
- **Cloud Services**: Vercel, NeonDB, Google Cloud Platform, Azure
- **Planned**: Email (Gmail/Outlook), cloud storage (Drive/Dropbox), social media, calendar, CRM, project management tools, Slack/Discord bots, Zapier/Make connectors

### 📦 Output Management
- File editor tool for reading, writing, and string replacement
- Workspace management with per-session directories
- File upload handler with base64 and text support
- Static file serving for workspace artifacts
- Terminal manager for command execution and output capture

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

**Client-Side:** Fyne native GUI, WebSocket client, future WebAssembly runtime for local execution.

**Server-Side:** Go-based orchestration engine with Gin HTTP/WS server, multi-provider LLM layer, tool/action framework, and sandboxed execution environments.

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

## 💰 Business Model

| Revenue Stream | Description |
|---|---|
| **Community Donations** | Voluntary donations from individuals and organizations who benefit from Water AI |
| **Enterprise Licensing** | Volume licensing and tailored solutions for businesses requiring dedicated support and SLAs |
| **Usage-Based Pricing** | Fair pricing based on inference and cloud compute consumption for heavy users |

---

## 🏛 The Visionary

| | |
|---|---|
| **Visionary** | **John Victor** |
| **Organization** | Stellarium Foundation |
| **Mission** | Leverage technology for global prosperity and human advancement |
| **Goal** | The Elevation to Eden |

John Victor, founder of the **Stellarium Foundation**, conceived Water AI as the technological cornerstone of a broader mission to uplift humanity. The Foundation's work spans multiple initiatives, with Water AI serving as the intelligent core that ties them together.

---

## 💵 Funding

**Funding Ask:** **$600,000** for core platform development, foundational model integration, and key engineering talent.

Funds will be allocated toward:
- **Core Orchestration Engine** — Advanced task decomposition, multi-model routing, and planning capabilities
- **Foundational Model Integrations** — Connecting 500+ specialized AI models across every domain
- **Key Engineering Talent** — Hiring world-class Go, AI/ML, and systems engineers
- **Infrastructure** — Cloud compute for development, testing, and initial deployment

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

## 🤝 Contributing

Water AI is an open-source project fostered by the **Stellarium Foundation**. We welcome developers who share the vision of human augmentation.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/AmazingAction`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **Apache 2.0 License** — see the [LICENSE](LICENSE) file for details.

---

<p align="center"><em>"Be water. Flow into the future."</em></p>
