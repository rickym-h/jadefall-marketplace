---
description: Preview your current statusline configuration with sample data
---

# Statusline Preview

Show the user what their current statusline looks like with sample data.

## Instructions

1. Check if ~/.claude/statusline.sh exists
   - If not, tell user to run `/statusline-builder:setup` first

2. Run the statusline script with sample JSON input to show a preview:

```bash
echo '{"model":{"display_name":"Claude Opus 4.5","id":"claude-opus-4-5-20251101"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":15000,"cache_creation_input_tokens":25000,"cache_read_input_tokens":30000}}}' | bash ~/.claude/statusline.sh
```

3. Display the output to the user and explain what each component shows

4. Optionally show previews with different models:

**Opus preview:**
```bash
echo '{"model":{"display_name":"Claude Opus 4.5"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":15000}}}' | bash ~/.claude/statusline.sh
```

**Sonnet preview:**
```bash
echo '{"model":{"display_name":"Claude Sonnet 4.5"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":15000}}}' | bash ~/.claude/statusline.sh
```

**Haiku preview:**
```bash
echo '{"model":{"display_name":"Claude Haiku 4.5"},"context_window":{"context_window_size":200000,"current_usage":{"input_tokens":15000}}}' | bash ~/.claude/statusline.sh
```

5. Tell the user they can run `/statusline-builder:setup` to modify their configuration
