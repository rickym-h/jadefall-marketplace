---
description: Display help for the /review command
---

# Code Review Command Help

## Usage

```
/review              # Review uncommitted changes (git diff)
/review --branch     # Review entire branch against main
/review help         # Display this help
```

## Flags

| Flag | Short | Description |
|------|-------|-------------|
| `--branch` | `-b` | Diff current branch against main instead of uncommitted changes |
| `--thorough` | `-t` | Force subagent mode even for small diffs |
| `--simple` | `-s` | Force single-pass mode even for large diffs |
| `--report` | `-r` | Save findings to `docs/reviews/YYYY-MM-DD-review.md` |
| `--spec <path>` | | Reference a spec document for validation |
| `--help` | | Display this help |

## Examples

```
/review                      # Quick review of staged/unstaged changes
/review -b                   # Review full branch before PR
/review -b --thorough        # Thorough multi-agent review of branch
/review --spec docs/spec.md  # Review against explicit spec document
/review -br                  # Branch review, save report
```

## Review Tiers

**[T1] Critical** - Must address before merging
- Spec adherence: Does it do what was asked, nothing more, nothing less?
- Clean code: Modular, maintainable, flexible, well-separated concerns

**[T2] Important** - Should address
- Appropriate error handling
- Reasonable test coverage
- Sensible dependencies

**[T3] Minor** - Nice to have
- Style consistency
- Naming clarity
- Documentation

## Subagent Mode

Automatically triggered when diff exceeds ~200 lines. Spawns three specialized reviewers in parallel:
1. **Spec Reviewer** - Validates against requirements
2. **Clean Code Reviewer** - Checks maintainability and modularity
3. **Overengineering Detector** - Finds unnecessary complexity

Use `--thorough` to force subagent mode, `--simple` to disable it.
