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

## Commands

### `/statusline-builder:setup`

Interactive setup wizard to build your custom statusline:
1. Select which components to include
2. Choose component order (or use recommended)
3. Generates `~/.claude/statusline.sh`
4. Configures Claude Code to use it

### `/statusline-builder:preview`

Preview your current statusline with sample data to see how it looks.

## Requirements

- **jq**: Required for JSON parsing
- **ccusage**: Optional, required for cost tracking components
  - Install with: `npx ccusage@latest`

## Installation

Add this plugin to your Claude Code configuration or install from the marketplace.

## Example Output

```
✦ Claude Opus 4.5 | ███░░░░░░░░░░░░ 20% | ⚡ $1.50 | 📅 $8.00 | Σ $40.00 | ⎇ main* | 📁 my-project | v2.1.14
```
