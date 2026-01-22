# Jadefall Marketplace

A Claude Code plugin marketplace featuring code quality and architecture review tools.

## Plugins

### Code Review Plugin

A comprehensive code quality review plugin that analyzes code against fundamental software engineering principles:

- **DRY (Don't Repeat Yourself)** - Identifies code duplication and suggests refactoring
- **KISS (Keep It Simple, Stupid)** - Flags over-complexity and unnecessary abstractions
- **YAGNI (You Aren't Gonna Need It)** - Spots speculative features and premature optimization
- **SOLID Principles** - Checks adherence to object-oriented design principles
  - Single Responsibility Principle
  - Open/Closed Principle
  - Liskov Substitution Principle
  - Interface Segregation Principle
  - Dependency Inversion Principle

Additionally provides feedback on architecture quality, maintainability, and readability.

## Installation

### Add the Marketplace

```bash
/plugin marketplace add ./path/to/jadefall-marketplace
```

Or if hosted on GitHub:

```bash
/plugin marketplace add username/jadefall-marketplace
```

### Install the Plugin

```bash
/plugin install code-review@jadefall-marketplace
```

## Usage

Select code in your editor or let the plugin review recent changes:

```bash
/review
```

The plugin will provide specific, actionable feedback on:
- Code duplication and refactoring opportunities
- Complexity issues and simplification suggestions
- Unnecessary features or premature optimizations
- SOLID principle violations
- Architecture and maintainability concerns

## License

MIT
