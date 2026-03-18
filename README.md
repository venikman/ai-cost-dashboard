# AI Cost Dashboard

A native macOS app that compares AI model pricing across providers in real time. See where you can save money on the same model.

![macOS](https://img.shields.io/badge/macOS-14%2B-black) ![Swift](https://img.shields.io/badge/Swift-6-orange) ![Tests](https://img.shields.io/badge/tests-49%20passing-green)

## Install

**Requirements:** macOS 14+ (Sonoma), Xcode or Swift toolchain

```bash
git clone https://github.com/venikman/ai-cost-dashboard.git
cd ai-cost-dashboard
swift build
open .build/debug/AICostDashboardApp
```

Or open `Package.swift` in Xcode and press `⌘R`.

## What it does

Fetches live pricing from **OpenRouter API** and **LiteLLM** and shows side-by-side comparisons for ~25 popular models across 7 providers:

| Direct | Aggregators |
|--------|------------|
| OpenAI | OpenRouter |
| Anthropic | AWS Bedrock |
| Google AI Studio | Azure OpenAI |
| | Google Vertex |

### Models tracked

Claude (Opus, Sonnet, Haiku) · GPT (4o, 4.1, o1, o3) · Gemini (2.0 Flash/Pro, 2.5) · DeepSeek (V3, R1) · Llama · Mistral · Cohere

## Features

- **3 views** — Grid, Table, Stream (`⌘1` `⌘2` `⌘3`)
- **Provider comparison** — click any model to see all providers with price diff
- **Savings badges** — green tag shows cheapest provider and how much you save
- **Stats banner** — total models, cheapest, most expensive, best savings, largest context
- **Price range indicator** — visual Low → Best → High across providers
- **Search & filter** — by model name or provider
- **Sort** — by name, price, context window, speed, savings
- **Auto-refresh** — every 15 min, manual with `⌘R`
- **Offline mode** — cached data on disk, works without internet
- **Dark theme** — Raycast-inspired design

## Data sources

| Source | What it provides | Auth |
|--------|-----------------|------|
| [OpenRouter API](https://openrouter.ai/api/v1/models) | Live aggregated pricing | None required |
| [LiteLLM pricing JSON](https://github.com/BerriAI/litellm) | Direct provider prices (Anthropic, OpenAI, Google, Bedrock, Azure, Vertex) | None required |

Prices are per-token from the APIs, converted to **$ per 1M tokens** for display.

## Tests

```bash
swift test
```

49 tests across 9 suites covering the full pipeline:

- **Data Pipeline E2E** — live API calls, parsing, merging
- **Model Matching** — deduplication across sources
- **ViewModel** — search, sort, filter logic
- **Detail Panel** — sidebar data completeness
- **Name Cleaning** — no raw prefixes or date suffixes
- **Price Formatting** — display values
- **Cache** — save/load round-trip
- **Provider** — enum correctness

## Architecture

```
Sources/AICostDashboard/
├── Models/          AIModel, Provider, ProviderPrice
├── Services/        OpenRouterAPI, LiteLLMDataSource, PricingService, ModelMatcher
├── ViewModels/      DashboardViewModel
├── Views/           DashboardView, TableView, GridView, StreamView, ModelDetailPanel, ...
└── Utilities/       Theme, PriceFormatter, Cache

Sources/AICostDashboardApp/
└── AICostDashboardApp.swift   (@main entry point)
```

## Keyboard shortcuts

| Key | Action |
|-----|--------|
| `⌘1` | Grid view |
| `⌘2` | Table view |
| `⌘3` | Stream view |
| `⌘R` | Refresh data |
| `⌘F` | Focus search |

## License

MIT
