---
description: Review and restructure CLAUDE.md files to reduce context bloat through hierarchical organization
argument-hint: Optional flags (--help, --report, --thorough)
---

# CLAUDE.md Cleanup

Interactive tool to review existing CLAUDE.md files for bloat and guide hierarchical restructuring.

## Parse Arguments

Parse the command arguments: `{{ args }}`

**Flags to detect:**
- `--help` or `help`: Show help and exit
- `--report` or `-r`: Generate report only, no interactive fixing
- `--thorough` or `-t`: Force detailed analysis even for small files
- `--path <directory>`: Analyze specific directory (default: current repo root)

If `help` or `--help` is present, show this help text and stop:

```
CLAUDE.md Cleanup - Review and restructure documentation to reduce context bloat

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
USAGE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  /claudemd-cleanup              Scan current repository
  /claudemd-cleanup --report     Generate report only (no fixing)
  /claudemd-cleanup --thorough   Detailed analysis for small files
  /claudemd-cleanup --path <dir> Analyze specific directory

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
WORKFLOW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1. Discovers all CLAUDE.md files recursively
  2. Analyzes for context bloat (size, code examples)
  3. Detects hierarchical split opportunities
  4. Guides interactive restructuring

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
ISSUE TIERS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  [T1] Critical - File >10KB or >8 code blocks, must split
  [T2] Important - File 5-10KB or 3-8 code blocks, consider splitting
  [T3] Minor - Missing guidelines or style issues

Run '/claudemd-cleanup --help-full' for size thresholds and best practices.
See also: /hierarchical-docs skill for detailed restructuring guidance
```

---

## Step 1: Discover CLAUDE.md Files

**Execute:** Find repository root with error handling:

```bash
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
  REPO_ROOT=$(pwd)
  echo "ℹ Not in a git repository, using current directory"
fi
```

Store the repository root.

**Execute:** Find all CLAUDE.md files with normalized paths:

```bash
if git rev-parse --git-dir > /dev/null 2>&1; then
  git ls-files 2>/dev/null | grep -i "CLAUDE.md" | sed 's|^|./|'
else
  find . -name "CLAUDE.md" -type f
fi
```

If no CLAUDE.md files are found:
```
No CLAUDE.md files found in this repository.

Would you like to:
1. Create a root CLAUDE.md file
2. Exit

This tool focuses on reviewing and improving existing CLAUDE.md files.
For creating new documentation, consider using /init or manually creating CLAUDE.md.
```

Exit if user chooses to exit or if creating new files (out of scope for this tool).

Count total files found and show summary:
```
Found 3 CLAUDE.md files:
  ./CLAUDE.md (876 bytes)
  ./plugins/ue5-style-guide/CLAUDE.md (15,234 bytes)
  ./plugins/code-quality/CLAUDE.md (3,421 bytes)

Analyzing for context bloat and restructuring opportunities...
```

---

## Step 2: Analyze Each File

For each CLAUDE.md file, analyze:

### 2.1 Size Analysis

**Execute:** Read file and calculate metrics:

```bash
FILE_SIZE=$(wc -c < "$filepath")
LINE_COUNT=$(wc -l < "$filepath")
# Token estimate: Markdown with code blocks tokenizes at ~3 chars per token
TOKEN_ESTIMATE=$(echo "$FILE_SIZE / 3" | bc)
```

**Size Thresholds** (from hierarchical-docs best practices):
- **<5KB** (5120 bytes): OK - no size issues
- **5-10KB** (5120-10240 bytes): [T2] Warning - consider splitting
- **>10KB** (10240+ bytes): [T1] Critical bloat - must split

Note: These thresholds are referenced throughout this workflow and in the help text.

### 2.2 Content Analysis

**Execute:** Count code blocks (each block has opening and closing backticks):

```bash
CODE_BLOCK_COUNT=$(grep -c '^```' "$filepath" | awk '{print int(($1 + 1) / 2)}')
```

**Code Block Thresholds**:
- **<3 blocks**: OK - appropriate level of examples
- **3-8 blocks**: [T2] Watch - may have implementation details
- **>8 blocks**: [T1] Critical - definitely has implementation details in root doc

Note: These thresholds are used in issue classification.

**Execute:** Check for patterns indicating misplaced content:

```bash
EXAMPLE_COUNT=$(grep -c -i "example:" "$filepath")
IMPL_COUNT=$(grep -c -i "implementation:" "$filepath")
EXTEND_COUNT=$(grep -c -i "how to extend" "$filepath")
```

Multiple matches indicate detailed implementation guidance that should live in module/subsystem docs.

### 2.3 Structure Analysis

**Execute:** Check if hierarchical documentation guidelines exist:

```bash
HAS_UPDATING_DOCS=$(grep -c -i "updating documentation" "$filepath")
HAS_HIERARCHICAL=$(grep -c -i "hierarchical" "$filepath")
HAS_SUBDIRECTORY_DOCS=$(grep -c -i "subdirectory CLAUDE.md" "$filepath")
```

If all counts are 0: [T3] Should add documentation maintenance guidelines

**Execute:** Check directory structure for natural split points:

```bash
PARENT_DIR=$(dirname "$filepath")
ls -d "$PARENT_DIR"/*/ 2>/dev/null
```

Look for common patterns that suggest natural splits:
- `Source/` directories (Unreal Engine plugins)
- `Public/` directories (subsystems)
- `skills/` directories (plugin skills)
- `commands/` directories (plugin commands)
- Module subdirectories

### 2.4 Detect Split Opportunities

For files with [T1] or [T2] size issues:

**Execute:** Validate potential split directories before suggesting:

```bash
# For each potential child directory (e.g., skills/asset-naming/):
if [ -d "$CHILD_DIR" ] && [ -w "$CHILD_DIR" ]; then
  # Check if CLAUDE.md already exists
  if [ -f "$CHILD_DIR/CLAUDE.md" ]; then
    echo "ℹ $CHILD_DIR/CLAUDE.md already exists (will ask about merging)"
  fi
  # Valid split target
else
  # Skip - directory doesn't exist or isn't writable
  continue
fi
```

Analyze content sections and match to validated subdirectories:
- Read file content
- Identify major sections (## headers)
- Check if section names match subdirectory names
- **Validate** directory exists and is writable
- Suggest moving section to subdirectory CLAUDE.md

Example detection logic:
```
If file has section "## Asset Naming"
AND directory "skills/asset-naming/" exists AND is writable
THEN suggest: Move "## Asset Naming" section to skills/asset-naming/CLAUDE.md
```

---

## Step 3: Present Findings

Organize all issues by tier and file:

```markdown
## Analysis Complete

### [T1] Critical Issues (Must Address)

1. **plugins/ue5-style-guide/CLAUDE.md** (15.2 KB, 23 code blocks)
   - File is 3x recommended size (>10KB threshold)
   - Contains 23 code examples (likely implementation details in root doc)
   - Detected sections matching subdirectories:
     * "Asset Naming" → skills/asset-naming/
     * "C++ Coding Standards" → skills/cpp-coding-standards/
     * "Blueprint Conventions" → skills/blueprints/
   - Missing hierarchical documentation guidelines

   **Suggested action**: Split into hierarchical structure
   - Root CLAUDE.md: Overview, architecture (target: 3-5KB)
   - skills/asset-naming/CLAUDE.md: Asset naming rules + examples
   - skills/cpp-coding-standards/CLAUDE.md: C++ standards + examples
   - skills/blueprints/CLAUDE.md: Blueprint conventions + examples

### [T2] Important Issues (Should Address)

None found.

### [T3] Minor Issues (Nice to Have)

1. **./CLAUDE.md** (876 bytes)
   - Missing "Updating Documentation" section
   - Suggestion: Add hierarchical documentation maintenance guidelines

---

**Summary**:
- Critical issues: 1 file
- Important issues: 0 files
- Minor issues: 1 file
- Total files analyzed: 3
```

If `--report` flag was set, save this report to `docs/reviews/YYYY-MM-DD-claudemd-review.md` and exit.

Otherwise, proceed to interactive fixing.

---

## Step 4: Interactive Restructuring

Process issues in order: [T1] → [T2] → [T3]

For each issue:

### 4.1 Present Issue Context

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[T1] Issue 1 of 1

File: plugins/ue5-style-guide/CLAUDE.md (15.2 KB)
Issue: Critical bloat - file is 3x recommended size

Current structure:
  - CLAUDE.md (15.2 KB) - everything in one file

Suggested structure:
  - CLAUDE.md (3-5 KB) - lean overview + architecture
  - skills/asset-naming/CLAUDE.md - asset naming rules
  - skills/cpp-coding-standards/CLAUDE.md - C++ standards
  - skills/blueprints/CLAUDE.md - blueprint conventions

This will reduce context by ~70% when working on specific skills.

Actions:
1. Apply restructuring (will create child docs and move content)
2. Show content preview (what moves where)
3. Skip this file
4. Stop cleanup

Your choice:
```

Wait for user input.

### 4.2 Handle User Choice

**Choice 1: Apply restructuring**

Proceed to Step 5 (Execute Restructuring) for this file.

**Choice 2: Show content preview**

For each suggested child doc:
- Show which sections would move
- Show first few lines of content
- Show estimated size of child doc

Then ask again for choice (return to 4.1).

**Choice 3: Skip this file**

Mark as skipped, continue to next issue.

**Choice 4: Stop cleanup**

Exit with summary of what was done so far.

---

## Step 5: Execute Restructuring

When user chooses to apply restructuring:

### 5.1 Create Backup

**Execute:** Create timestamped backup with error handling:

```bash
BACKUP_PATH="${filepath}.bak.$(date +%Y%m%d_%H%M%S)"
if cp "$filepath" "$BACKUP_PATH"; then
  echo "✓ Backup created: $BACKUP_PATH"
else
  echo "✗ ERROR: Failed to create backup. Aborting restructuring."
  echo "  Check file permissions and disk space."
  exit 1
fi
```

**Critical:** If backup fails, abort the entire restructuring to prevent data loss.

### 5.2 Create Child CLAUDE.md Files

For each suggested child doc (e.g., `skills/asset-naming/CLAUDE.md`):

**Canonical Template for Child CLAUDE.md**:
```markdown
# [Section Title]

[Moved content from root CLAUDE.md]

---

*This documentation is part of the hierarchical CLAUDE.md structure.*
*For overall architecture, see the [root CLAUDE.md](../../CLAUDE.md).*
```

Note: This is the standard template for ALL child documentation files. The "Documentation Structure" section in the root file (Step 5.3) simply lists these files - it is NOT a different template.

**Execute:** Create child file with error handling:

```bash
CHILD_PATH="$CHILD_DIR/CLAUDE.md"

# Check if file already exists
if [ -f "$CHILD_PATH" ]; then
  # Ask user: merge or skip
  echo "ℹ $CHILD_PATH already exists"
  # [User choice handling]
fi

# Write content
if echo "$CHILD_CONTENT" > "$CHILD_PATH"; then
  FILE_SIZE=$(wc -c < "$CHILD_PATH")
  echo "✓ Created $CHILD_PATH (${FILE_SIZE} bytes)"
else
  echo "✗ ERROR: Failed to create $CHILD_PATH"
  echo "  Rolling back: restoring from backup..."
  cp "$BACKUP_PATH" "$filepath"
  exit 1
fi
```

**Error Handling:** If any child file creation fails, restore from backup and abort.

### 5.3 Update Root CLAUDE.md

Extract only the overview/architecture content from root.

**Execute:** Create new lean root structure with error handling:
```markdown
# [Project Name]

[Brief overview - 1-2 sentences]

## Status

[Development status, dependencies if critical]

## Architecture

[High-level architecture - simplified diagram or description]

[Core class/component table - names and one-line purposes only]

## Updating Documentation

This project uses hierarchical CLAUDE.md files. When updating documentation:

- **This root file**: Architecture overview, core concepts only (keep under 5KB)
- **Module-specific details**: Update the CLAUDE.md in the relevant subdirectory
- **Skill-specific details**: Update skills/<skill-name>/CLAUDE.md

Do NOT add detailed code examples or implementation specifics to this root file.
Place them in the appropriate subdirectory CLAUDE.md so context is only loaded
when working on relevant files.

## Documentation Structure

- [skills/asset-naming/CLAUDE.md](skills/asset-naming/CLAUDE.md) - Asset naming conventions
- [skills/cpp-coding-standards/CLAUDE.md](skills/cpp-coding-standards/CLAUDE.md) - C++ coding standards
- [skills/blueprints/CLAUDE.md](skills/blueprints/CLAUDE.md) - Blueprint conventions
```

**Execute:** Write updated root file with error handling:

```bash
if echo "$NEW_ROOT_CONTENT" > "$filepath"; then
  NEW_SIZE=$(wc -c < "$filepath")
  OLD_SIZE=$(wc -c < "$BACKUP_PATH")
  echo "✓ Updated $filepath (now ${NEW_SIZE} bytes, was ${OLD_SIZE} bytes)"
  echo "✓ Added documentation maintenance guidelines"
else
  echo "✗ ERROR: Failed to update root CLAUDE.md"
  echo "  Rolling back: restoring from backup and removing child files..."
  cp "$BACKUP_PATH" "$filepath"
  # Remove created child files
  for child in $CREATED_CHILDREN; do
    rm "$child"
  done
  exit 1
fi
```

**Error Handling:** If root update fails, restore backup and remove any created child files to maintain consistency.

### 5.4 Verify Results

**Execute:** Check new file sizes:

```bash
wc -c "$root_filepath" $child_filepaths
```

Show verification with **accurate** context calculations:

```
Verification:
  Root: 4.2 KB (72% reduction from 15.2 KB)
  skills/asset-naming/CLAUDE.md: 2.1 KB
  skills/cpp-coding-standards/CLAUDE.md: 3.4 KB
  skills/blueprints/CLAUDE.md: 1.8 KB

Context when working on asset-naming:
  Before restructuring: 15.2 KB (everything loaded)
  After restructuring: 6.3 KB (root 4.2 KB + child 2.1 KB loaded together)
  Savings: 8.9 KB (58% reduction)

Note: Claude Code loads BOTH root and child CLAUDE.md when working in subdirectories.
The savings come from NOT loading the other child docs (cpp-coding-standards, blueprints).
```

Mark issue as fixed, continue to next issue.

---

## Step 6: Handle Minor Issues

For [T3] issues (like missing maintenance guidelines):

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
[T3] Issue 1 of 1

File: ./CLAUDE.md (876 bytes)
Issue: Missing hierarchical documentation maintenance guidelines

This project is small and doesn't need splitting, but should include
guidelines for future growth.

Actions:
1. Add documentation maintenance section
2. Skip

Your choice:
```

If user chooses to add, **execute** with error handling:

```bash
MAINTENANCE_SECTION='

## Updating Documentation

When this project grows, consider hierarchical CLAUDE.md files:
- Keep root CLAUDE.md under 5KB (overview + architecture only)
- Add subdirectory CLAUDE.md files for detailed module documentation
- See /hierarchical-docs skill for restructuring guidance'

if echo "$MAINTENANCE_SECTION" >> "$filepath"; then
  echo "✓ Added documentation maintenance guidelines to $filepath"
else
  echo "✗ ERROR: Failed to update file. Check permissions."
  exit 1
fi
```

---

## Step 7: Final Summary

After processing all issues:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Cleanup Complete!

Summary:
  Issues found: 2
  Issues fixed: 2
  Issues skipped: 0

Changes made:
  Files created: 3
    - skills/asset-naming/CLAUDE.md
    - skills/cpp-coding-standards/CLAUDE.md
    - skills/blueprints/CLAUDE.md

  Files modified: 2
    - plugins/ue5-style-guide/CLAUDE.md (15.2 KB → 4.2 KB)
    - ./CLAUDE.md (added maintenance guidelines)

  Backups created: 1
    - plugins/ue5-style-guide/CLAUDE.md.bak.20260201_143022

Context savings:
  When working on specific skills: ~50-60% reduction in loaded context
  (Hierarchical loading: root + relevant child only, not all children)

Next steps:
  - Review the restructured files
  - Commit changes with descriptive message
  - Monitor context usage in future sessions

Use /hierarchical-docs skill for guidance on maintaining hierarchical documentation.
```

---

## Error Handling & Rollback

**If any operation fails during restructuring:**

1. **Backup failure**: Abort immediately, do not proceed
2. **Child file creation failure**: Restore from backup, remove any created children
3. **Root file update failure**: Restore from backup, remove all created children
4. **Permission errors**: Report to user, abort operation

**Rollback procedure:**
```bash
# Restore original file
cp "$BACKUP_PATH" "$filepath"

# Remove any created child files
for child_file in "${CREATED_FILES[@]}"; do
  if [ -f "$child_file" ]; then
    rm "$child_file"
    echo "Removed $child_file"
  fi
done

echo "✓ Rollback complete. Repository restored to original state."
```

**User can manually rollback:**
```bash
# Find backup files
ls -t *.bak.* | head -1

# Restore from backup
cp <backup_file> CLAUDE.md
```

---

## Important Notes & Best Practices

**Size Thresholds** (defined in Step 2.1, referenced throughout):
- <5KB (5120 bytes): OK
- 5-10KB (5120-10240 bytes): [T2] Consider splitting
- >10KB (10240+ bytes): [T1] Must split

**Code Block Thresholds** (defined in Step 2.2, used for issue classification):
- <3 blocks: OK
- 3-8 blocks: [T2] Watch for implementation details
- >8 blocks: [T1] Has implementation details

**Best Practices** (from humanlayer.dev and code.claude.com):
- Root CLAUDE.md should be <5KB (see thresholds above)
- Keep only broadly applicable content in root
- Use progressive disclosure via subdirectory CLAUDE.md files
- Prefer pointers over copies (file:line references instead of code snippets)
- Don't use Claude as a linter (delegate to deterministic tools)

**Hierarchical Loading Behavior**:
Claude Code automatically loads CLAUDE.md files from parent directories when reading any file:
- Working on `skills/asset-naming/Foo.cpp` loads: root CLAUDE.md + skills/asset-naming/CLAUDE.md
- Working on `Source/Bar.cpp` loads: only root CLAUDE.md

This is why keeping root lean is critical - it loads for EVERY file read.

**When to Split**:
- Root file >5KB
- File contains detailed code examples for specific subsystems
- Working on one area loads irrelevant context from another
- Plugin has multiple distinct modules/subsystems

**Safety**:
- Always creates timestamped backups before modifications
- Requires user confirmation for each restructuring
- Can skip any issue and continue
- Can stop cleanup at any time
