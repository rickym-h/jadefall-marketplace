---
description: Restructure CLAUDE.md files into hierarchical documentation for context-efficient loading
---

# Hierarchical Documentation Structure

Use this skill when CLAUDE.md files become too large (>5KB) or contain detailed implementation specifics that bloat context when working on unrelated parts of the codebase.

## The Problem

Claude Code automatically loads CLAUDE.md files from all parent directories when reading any file. A monolithic CLAUDE.md means every file read loads the entire documentation, wasting context on irrelevant details.

## The Solution

Split documentation hierarchically so context is only loaded when relevant:

```
Plugin/
├── CLAUDE.md                          # Lean: architecture overview only
└── Source/Module/
    ├── CLAUDE.md                      # Module: APIs, types, patterns
    └── Public/Subsystem/
        └── CLAUDE.md                  # Subsystem: detailed examples, extension patterns
```

## When to Apply

- Root CLAUDE.md exceeds ~5KB
- File contains detailed code examples for specific subsystems
- Plugin has multiple distinct modules or subsystems
- Working on one area loads irrelevant context from another

## Restructuring Process

### 1. Analyze Current Structure

Identify natural split points:
- **Modules**: Separate compilation units (e.g., `GridForge`, `GridForgeGeneration`)
- **Subsystems**: Distinct functional areas (e.g., `Placement/`, `Preview/`, `Jobs/`)
- **Complexity clusters**: Areas with lots of examples or extension patterns

### 2. Create Root CLAUDE.md (Lean)

Keep only:
- Plugin overview (1-2 sentences)
- Status and dependencies
- Development philosophy
- **Documentation maintenance guidelines** (critical!)
- Coding principles (brief)
- Architecture diagram (simplified)
- Core class table (names and one-line purposes only)
- Links to sub-documentation

**Target size**: 3-5KB

### 3. Create Module-Level CLAUDE.md

Place in `Source/<Module>/CLAUDE.md`. Include:
- Directory structure
- Key APIs and functions
- Type definitions
- Module-specific patterns
- Dependencies

**Target size**: 3-6KB per module

### 4. Create Subsystem-Level CLAUDE.md

Place in `Public/<Subsystem>/CLAUDE.md`. Include:
- Detailed code examples
- Extension patterns
- Implementation specifics
- Edge cases and gotchas

**Target size**: 3-8KB per subsystem

### 5. Add Documentation Maintenance Guidelines

**Critical**: Add this section to the root CLAUDE.md:

```markdown
## Updating Documentation

This plugin uses hierarchical CLAUDE.md files. When updating documentation:

- **This root file**: Architecture overview, core class list, high-level concepts only
- **Module-specific details**: Update the CLAUDE.md in the relevant `Source/<Module>/` directory
- **Subsystem-specific details**: Update the CLAUDE.md in the relevant subdirectory

Do NOT add detailed code examples or implementation specifics to this root file.
Place them in the appropriate subdirectory CLAUDE.md so context is only loaded
when working on relevant files.
```

## Example Split

**Before** (45KB monolithic):
```
Plugin/CLAUDE.md
├── Overview
├── Architecture (detailed)
├── Handler patterns (15KB of examples)
├── Preview system (10KB of examples)
├── Generation module (20KB of examples)
└── Everything else
```

**After** (hierarchical):
```
Plugin/CLAUDE.md (4KB)
├── Overview, architecture diagram, class table
└── Links to sub-docs

Source/GridForge/CLAUDE.md (5KB)
├── Module APIs, types, utilities

Source/GridForge/Public/Placement/CLAUDE.md (8KB)
├── Handler patterns, extension examples

Source/GridForge/Public/Preview/CLAUDE.md (4KB)
├── ISM system, sessions, materials

Source/GridForgeGeneration/CLAUDE.md (5KB)
├── Generation architecture, thread safety

Source/GridForgeGeneration/Public/Passes/CLAUDE.md (5KB)
├── Custom pass creation examples
```

## Context Loading Behavior

After restructuring:
- **Any file in plugin**: Loads only lean root doc (~4KB)
- **File in Placement/**: Loads root + Placement doc (~12KB)
- **File in Generation/Passes/**: Loads root + Generation + Passes (~14KB)

Typical context savings: 60-80% reduction vs monolithic approach.

## Checklist

- [ ] Root CLAUDE.md under 5KB
- [ ] Each sub-doc under 8KB
- [ ] Documentation maintenance guidelines added to root
- [ ] Links between docs are correct
- [ ] No orphaned detailed examples in root
- [ ] Commit message explains the restructuring
