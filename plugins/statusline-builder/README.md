# Statusline Builder

Build and customize your Claude Code statusline with selectable components.

## Features

Create a personalized statusline by choosing which components to display:

| Component | Symbol | Description |
|-----------|--------|-------------|
| **Model** | ✦/◆/⬦ | Current model with color (Opus=lavender, Sonnet=blue, Haiku=mint) |
| **Context Bar** | █░ | Visual progress bar showing context window usage |
| **Session Cost** | ⚡ | Current session cost (requires ccusage) |
| **Daily Cost** | 📅 | Today's total cost (requires ccusage) |
| **Total Cost** | Σ | Cumulative cost (requires ccusage) |
| **Git Branch** | ⎇ | Current branch with dirty/untracked indicators |
| **Directory** | 📁 | Current directory name |
| **Project** | 📦 | Project name from manifest files |
| **Version** | v | Claude Code version |
| **Auth** | 🏢/👤/🔑 | Account type: company org (green), personal subscription (blue), API key (peach), not logged in (red). Optional email display. |

## Usage

### `/statusline-builder:setup`

Interactive setup wizard to build your custom statusline:
1. Select which components to include
2. Choose component order (or use recommended)
3. Generates and verifies `~/.claude/statusline.sh`
4. Configures Claude Code to use it

Run again at any time to modify your configuration.

## Requirements

- **jq**: Required for JSON parsing
- **ccusage**: Optional, required for cost tracking components
  - Install with: `npx ccusage@latest`

## Installation

Add this plugin to your Claude Code configuration or install from the marketplace.

## Example Output

```
✦ Claude Opus 4.5 | ███░░░░░░░░░░░░ 20% | ⚡ $1.50 | 📅 $8.00 | Σ $40.00 | ⎇ main* | 📁 my-project | v2.1.14 | 🏢 PortSwigger Ltd (your.name@portswigger.net)
```

### Auth Display Variants

| Account type | Without email | With email |
|---|---|---|
| Company (via `/login`) | `🏢 PortSwigger Ltd` | `🏢 PortSwigger Ltd (your.name@portswigger.net)` |
| Personal subscription | `👤 Pro` | `👤 Pro (user@gmail.com)` |
| Custom API key | `🔑 API` | `🔑 API` (no email available) |
| Not logged in | `🔑 ✗` | `🔑 ✗` |
