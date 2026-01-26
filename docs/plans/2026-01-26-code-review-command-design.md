# Code Review Command Design

## Overview

A comprehensive `/review` command for the code-quality plugin that checks code against the spec, prevents overengineering, and ensures clean, maintainable code.

## Command Interface

```
/review              # Review uncommitted changes (git diff)
/review --branch     # Review entire branch against main
/review help         # Display usage information
```

**Flags:**
- `--branch` or `-b` - Diff current branch against main instead of uncommitted changes
- `--thorough` or `-t` - Force subagent mode even for small diffs
- `--simple` or `-s` - Force single-pass mode even for large diffs
- `--report` or `-r` - Save findings to `docs/reviews/YYYY-MM-DD-review.md`
- `--spec <path>` - Explicitly reference a spec document for validation
- `--help` or `help` - Display usage information

## Tiered Review Structure

### Tier 1: Critical (Must address before merging)

**Spec Adherence:**
- Does the code do exactly what was asked—no more, no less?
- Are there features built for hypothetical future requirements?
- Is there unnecessary abstraction or configurability?

**Clean Code:**
- Is the code modular with clear separation of concerns?
- Is it maintainable—easy to understand, modify, and extend?
- Is it flexible without being overengineered?
- Are components loosely coupled and cohesive?
- Can future developers easily work with this code?

### Tier 2: Important (Should address)

- Appropriate error handling (not excessive, not missing)
- Reasonable test coverage for the changes
- Dependencies are sensible and not overly coupled
- No premature optimizations

### Tier 3: Minor (Nice to have)

- Project conventions and style consistency
- Naming clarity
- Code smells (duplication, magic numbers)
- Documentation (sufficient but not excessive)

## Subagent Architecture

When triggered (auto for >200 lines changed, or `--thorough` flag):

**Agent 1: Spec Reviewer**
- Receives: The diff, conversation context, optional spec document
- Focus: Implementation matches requirements, no scope creep, nothing missing

**Agent 2: Clean Code Reviewer**
- Receives: The diff only (fresh context)
- Focus: Modularity, maintainability, flexibility, separation of concerns

**Agent 3: Overengineering Detector**
- Receives: The diff, brief problem statement
- Focus: Unnecessary abstraction, YAGNI violations, speculative features

**Orchestration:**
1. Main agent gathers diff and context
2. Spawns all three agents in parallel
3. Collects and deduplicates findings
4. Merges into tiered report

## Output

Issues labeled by tier: `[T1]`, `[T2]`, `[T3]`

Report format (when `--report` used):
- Review metadata (date, branch, diff stats)
- Findings organized by tier
- Summary with issue counts
