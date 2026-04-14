---
name: setup
description: Build a custom statusline by selecting which components to display
argument-hint: Optional component preset (minimal, standard, full)
disable-model-invocation: true
allowed-tools: Bash(chmod *) Bash(cat *) Bash(command -v *)
---

# Statusline Builder Setup

Guide the user through creating a custom Claude Code statusline.

## Prerequisites

Verify `jq` is installed (`command -v jq`). If missing, tell the user how to install it for their platform and stop.

## Setup Flow

### 1. Check for existing statusline

Check if `~/.claude/statusline.sh` already exists. If so, ask if the user wants to modify or start fresh.

### 2. Component Selection

Read the template at `${CLAUDE_PLUGIN_ROOT}/scripts/statusline-template.sh` to see all available components. Each component is marked with `# {{BEGIN:component_id}}` and `# {{END:component_id}}` blocks.

Present all components to the user and let them choose which to include. Cost components (daily_cost, monthly_cost) require the `ccusage` tool — mention this. Note: costs >= $10 are automatically displayed as whole dollars (e.g. "$449" instead of "$449.53") for compactness — mention this when the user selects cost components.

### 2a. Auth Component Options

If the user selects the **auth** component, show them this table of what the auth display looks like for each account type, with and without the email option:

| Account type | Without email | With email |
|---|---|---|
| Company (via `/login`) | `🏢 PortSwigger Ltd` | `🏢 PortSwigger Ltd (your.name@portswigger.net)` |
| Personal subscription | `👤 Pro` | `👤 Pro (user@gmail.com)` |
| Custom API key | `🔑 API` | `🔑 API` (no email available) |
| Not logged in | `🔑 ✗` | `🔑 ✗` |

Ask the user: **"Would you like to show your email address in brackets after the auth label?"**

Record their choice — it controls the `{{AUTH_SHOW_EMAIL}}` placeholder during generation (step 4).

### 3. Order Selection

If the user selected multiple components, ask about order: recommended default or custom.

Default order: model, context, daily_cost, monthly_cost, git, directory, project, auth

### 4. Generate Statusline

Generate `~/.claude/statusline.sh` from the template by including only the selected components:
- Always include the color definitions and separator
- Include component code blocks only for selected components (between their `{{BEGIN:X}}` and `{{END:X}}` markers)
- If no cost components selected, exclude the entire costs block
- Build the output section with only selected components (the `{{OUTPUT:X}}` lines)
- Remove all `{{` template markers from the final script
- Update the `{{COMPONENTS}}` comment with selected components
- Set `{{HAS_COSTS}}` to `"true"` or `"false"` based on whether any cost components were selected
- Set `{{AUTH_SHOW_EMAIL}}` to `"true"` or `"false"` based on the user's choice in step 2a (defaults to `"false"` if auth was not selected)

Make it executable: `chmod +x ~/.claude/statusline.sh`

### 5. Configure Claude Code

Update `~/.claude/settings.json` to include:
```json
"statusLine": {
  "type": "command",
  "command": "~/.claude/statusline.sh",
  "padding": 0
}
```

Preserve any existing settings in the file. Read the file first, then use the Edit tool to add or update the `statusLine` key.

### 6. Verify

Run the generated script with sample data to confirm it works:

```bash
echo '{"model":{"display_name":"Claude Sonnet 4"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":15000,"cache_creation_input_tokens":25000,"cache_read_input_tokens":30000}}}' | ~/.claude/statusline.sh
```

If it produces output, show the user what their statusline looks like and confirm setup is complete. If it errors, troubleshoot (check jq, permissions, syntax with `bash -n`).

Tell the user they can re-run `/statusline-builder:setup` to modify their configuration, and they may need to restart Claude Code for changes to take effect. If cost components were selected, remind them about `npx ccusage@latest`.
