---
description: Code review for quality, spec adherence, and clean code principles
---

# Code Review

Review code changes for spec adherence, clean code principles, and quality.

## Parse Arguments

Parse the command arguments: `{{ args }}`

**Flags to detect:**
- `--branch` or `-b`: Review branch diff against main
- `--thorough` or `-t`: Force subagent mode
- `--simple` or `-s`: Force single-pass mode
- `--report` or `-r`: Save findings to file
- `--spec <path>`: Reference a spec document
- `--help` or `help`: Show help (invoke `/review-help` instead)

If `help` or `--help` is present, display the help information from the review-help skill and stop.

## Gather the Diff

**Default (no `--branch`):**
```bash
git diff
git diff --cached
```
Combine staged and unstaged changes.

**With `--branch` flag:**
```bash
git merge-base HEAD main
git diff <merge-base>..HEAD
```
Get all changes on current branch since diverging from main.

Count the lines changed to determine review mode.

## Determine Review Mode

- If `--thorough` flag: Use subagent mode
- If `--simple` flag: Use single-pass mode
- If diff > 200 lines: Use subagent mode
- Otherwise: Use single-pass mode

## Load Spec Context

1. Check if `--spec <path>` was provided - read that file
2. Otherwise, use conversation context (what the user asked for in this session)
3. If no context available, note that spec validation will be limited

## Execute Review

### Single-Pass Mode

Review the diff against all criteria in one pass:

**Tier 1: Critical (Must address)**

*Spec Adherence:*
- Does the code do exactly what was asked—no more, no less?
- Are there features built for hypothetical future requirements?
- Is there unnecessary abstraction or configurability?
- Is anything missing from the requirements?

*Clean Code:*
- Is the code modular with clear separation of concerns?
- Is it maintainable—easy to understand, modify, and extend?
- Is it flexible without being overengineered?
- Are components loosely coupled and cohesive?
- Can future developers easily work with this code?

**Tier 2: Important (Should address)**
- Appropriate error handling (not excessive, not missing)
- Reasonable test coverage for the changes
- Dependencies are sensible and not overly coupled
- No premature optimizations

**Tier 3: Minor (Nice to have)**
- Project conventions and style consistency
- Naming clarity
- Code smells (duplication, magic numbers)
- Documentation (sufficient but not excessive)

### Subagent Mode

Spawn three specialized agents in parallel using the Task tool:

**Agent 1: Spec Reviewer**
```
Prompt: Review this diff against the provided requirements/context.

Requirements/Context:
[Include conversation context or spec document]

Diff:
[Include the diff]

Check:
- Does the implementation match what was requested?
- Is anything missing from the requirements?
- Is there scope creep (features not asked for)?
- Are there features built for hypothetical future needs?

Report findings as [T1] issues. Be specific with file:line references.
```

**Agent 2: Clean Code Reviewer**
```
Prompt: Review this diff for clean code principles.

Diff:
[Include the diff]

Check:
- Is the code modular with clear separation of concerns?
- Is it maintainable—easy to understand and modify?
- Is it flexible and extensible without being overengineered?
- Are components loosely coupled and cohesive?
- Can future developers easily work with this code?

Report findings as [T1] for critical issues, [T2] for important. Be specific with file:line references.
```

**Agent 3: Overengineering Detector**
```
Prompt: Review this diff for overengineering.

Problem being solved:
[Brief problem statement from context]

Diff:
[Include the diff]

Check:
- Unnecessary abstractions or indirection
- YAGNI violations (features for hypothetical future needs)
- Premature optimizations
- Excessive configurability or extensibility
- Solving a generalized problem instead of the actual problem

Report findings as [T1] issues. Be specific with file:line references.
```

After all agents complete, collect and deduplicate findings.

## Present Findings

Format findings by tier:

```markdown
## Code Review Results

**Diff:** [X files changed, Y insertions, Z deletions]
**Mode:** [Single-pass | Thorough (subagent)]

### [T1] Critical Issues
[List each issue with file:line reference and explanation]

### [T2] Important Issues
[List each issue]

### [T3] Minor Issues
[List each issue]

### Summary
- Critical: X issues
- Important: Y issues
- Minor: Z issues
```

If no issues found in a tier, note "None found."

## Save Report (if `--report` flag)

Write findings to `docs/reviews/YYYY-MM-DD-review.md` with:
- Review metadata (date, branch, diff stats, mode)
- Full findings organized by tier
- Summary

Create `docs/reviews/` directory if it doesn't exist.

## Key Principles

- **Spec adherence and clean code are equally important** - both are Tier 1
- **Overengineering is a critical issue** - unnecessary complexity hurts maintainability
- **Be specific** - always include file:line references
- **Be actionable** - explain why something is an issue and how to address it
- **Don't nitpick** - focus on issues that actually matter
