# Jadefall Marketplace

This is a Claude Code plugin marketplace containing curated plugins for code quality and development workflows.

## Adding New Plugins

When adding a new plugin to this marketplace:

1. Create the plugin directory under `plugins/<plugin-name>/`
2. Add the plugin's `plugin.json` and any skill files
3. **Register the plugin in `.claude-plugin/marketplace.json`** by adding an entry to the `plugins` array:

```json
{
  "name": "<plugin-name>",
  "source": "./plugins/<plugin-name>",
  "description": "<brief description>",
  "version": "1.0.0",
  "keywords": ["<relevant>", "<keywords>"],
  "category": "development"
}
```

Without this registration, the plugin will not be discoverable or installable from the marketplace.
