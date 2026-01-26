---
description: Build a custom statusline by selecting which components to display
argument-hint: Optional component preset (minimal, standard, full)
---

# Statusline Builder Setup

Guide the user through creating a custom Claude Code statusline.

## Available Components

| ID | Symbol | Name | Description |
|----|--------|------|-------------|
| model | ✦/◆/⬦ | Model | Current model with color-coded symbol (Opus=lavender, Sonnet=blue, Haiku=mint) |
| context | █░ | Context Bar | Visual progress bar showing context window usage percentage |
| daily_cost | 📅 | Daily Cost | Today's total cost from ccusage |
| monthly_cost | Σ | Monthly Cost | Current calendar month cost from ccusage (Claude retains ~30 days of logs) |
| git | ⎇ | Git Branch | Current branch with dirty (*) and untracked (+) indicators |
| directory | 📁 | Directory | Current directory basename |
| project | 📦 | Project Name | Project name from package.json, Cargo.toml, etc. |
| version | v | Version | Claude Code version number |

## Setup Flow

### Step 0: Check dependencies

First, verify that `jq` is installed (required for the statusline script to work):

```bash
command -v jq
```

If jq is not found, stop and tell the user:
> **Error: jq is required but not installed.**
>
> Install it with:
> - **macOS**: `brew install jq`
> - **Ubuntu/Debian**: `sudo apt install jq`
> - **Fedora**: `sudo dnf install jq`
> - **Arch**: `sudo pacman -S jq`

Do not proceed until jq is installed.

### Step 1: Check for existing statusline

Check if the user already has a statusline configured:

```bash
ls -la ~/.claude/statusline.sh 2>/dev/null
```

- If the file exists, ask if user wants to modify or start fresh
- If not found, proceed to component selection

### Step 2: Component Selection

Use AskUserQuestion with multiSelect=true to ask which components to include.

Present two questions:
1. "Which display components do you want?" with options:
   - Model (shows current model with color)
   - Context bar (visual usage indicator)
   - Git branch (current branch + status)
   - Directory (current folder name)
   - Project name (from manifest files)
   - Version (Claude Code version)

2. "Which cost components do you want?" (requires ccusage) with options:
   - Daily cost (today's total)
   - Monthly cost (current month)
   - None (skip cost tracking)

### Step 3: Order Selection

If user selected multiple components, ask about order:
- Recommended order (sensible default)
- Custom order

Default order: model, context, [costs], git, directory, project, version

### Step 4: Generate Statusline

Read the template from ${CLAUDE_PLUGIN_ROOT}/scripts/statusline-template.sh

Generate a statusline.sh that includes only the selected components:
- Always include the color definitions
- Include component code blocks only for selected components
- If no cost components selected, skip all ccusage-related code
- Build the output string with only selected components

Write the generated script to ~/.claude/statusline.sh

Then make it executable:
```bash
chmod +x ~/.claude/statusline.sh
```

### Step 5: Configure Claude Code

Configure Claude Code to use the statusline by updating the settings file.

1. First, read the current settings file to check its existing contents:
   ```bash
   cat ~/.claude/settings.json 2>/dev/null || echo "{}"
   ```

2. Use the Edit tool to update `~/.claude/settings.json`, setting the `statusline` key to `~/.claude/statusline.sh`. Preserve any existing settings in the file.

3. Verify the configuration was applied correctly by reading the file back:
   ```bash
   cat ~/.claude/settings.json
   ```

4. Confirm that the `statusline` key is present and set to `~/.claude/statusline.sh`. If not, report the error to the user.

### Step 6: Verify Statusline Output

Run a preview to verify the statusline script works correctly:

```bash
echo '{"model":{"display_name":"Claude Sonnet 4"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":15000,"cache_creation_input_tokens":25000,"cache_read_input_tokens":30000}}}' | ~/.claude/statusline.sh
```

Check the output:
- If it produces colored output with the selected components, the setup succeeded
- If it shows errors or empty output, troubleshoot:
  - Check if jq is working: `echo '{"test":1}' | jq .`
  - Check script permissions: `ls -la ~/.claude/statusline.sh`
  - Check for syntax errors: `bash -n ~/.claude/statusline.sh`

### Step 7: Confirmation

Tell the user:
- Which components were included
- Show the preview output from Step 6 so they can see what their statusline looks like
- Show the actual statusline setting from the config file
- They can run `/statusline-builder:preview` anytime to see the statusline
- They can run `/statusline-builder:setup` again to modify
- They may need to restart Claude Code for the statusline to take effect

## Important Notes

- If ccusage components are selected, remind user to run `npx ccusage@latest` if they haven't already
- The statusline script requires `jq` to be installed
- Git component only shows when inside a git repository
- Project name only shows if different from directory name
