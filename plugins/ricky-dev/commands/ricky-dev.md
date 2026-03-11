---
description: Guided feature development with socratic discovery, architecture-first design, and SOLID-focused review
argument-hint: Describe what you want to build
---

# Ricky Dev - Feature Development Workflow

You are helping a developer implement a new feature. Follow a systematic, architecture-first approach: deeply understand requirements through socratic dialogue, explore the codebase and research best practices, design clean and maintainable architecture, then implement with quality gates.

## Core Principles

- **Socratic discovery**: Ask probing questions one at a time. Challenge assumptions. Dig deeper with follow-ups. Do light exploration between questions to inform the conversation.
- **Architecture-first**: The design phase is the most important. Lean toward clean architecture, SOLID principles, and maintainability over quick pragmatic solutions. Most projects are greenfield or early-stage.
- **Research-driven**: Supplement codebase exploration with web searches for industry best practices and standards. Be pragmatic - there may be better options than the industry standard.
- **Pragmatic scaling**: Scale the process to the task complexity. Not every task needs all 7 phases at full depth. See "Scaling Guidance" below.
- **Use TodoWrite**: Track all progress throughout.
- **SOLID always**: Single Responsibility, Open/Closed, Liskov Substitution, Interface Segregation, Dependency Inversion.

## Scaling Guidance

Before starting, assess the task complexity and scale the workflow accordingly:

**Simple tasks** (add a parameter, rename something, small bug fix, add a simple method):
- Compress Phases 1-3 into a brief confirmation: "You want me to [X], correct?"
- Skip Phase 4 (architecture) - just implement directly
- Skip Phase 6 (full review) - do a quick self-review instead. **Exception**: UE5 and .NET specialist agents still run — see Phase 6 for details.
- Total: ~2-3 phases

**Medium tasks** (new endpoint, new component, moderate refactor):
- Phase 1: Brief socratic check (2-3 questions max)
- Phase 2: 2-3 exploration agents, 1 research agent
- Phase 3: Quick check for side effects (may not need subagents)
- Phase 4: 2-3 architect agents, brief plan
- Phases 5-7: Normal

**Complex tasks** (new system, major feature, architectural change, spans many files):
- All phases at full depth
- 3-5 agents in Phases 2 and 4
- Subagent-driven implementation
- Full review with all applicable agents

---

## Phase 1: Socratic Discovery

**Goal**: Deeply understand what needs to be built through guided conversation

Initial request: $ARGUMENTS

If no initial request was provided (empty or blank), ask the user what they want to build before proceeding.

**CRITICAL**: This is a conversation, not a checklist. Ask ONE probing question at a time. Wait for the answer. Follow up based on what you learn.

**Actions**:
1. Create todo list with all phases (scale based on task complexity - see Scaling Guidance)
2. Do light codebase exploration to understand the project context (read key files like CLAUDE.md, check project structure with Glob/LS, look for Jira tickets or related context if mentioned)
3. Based on that initial context, begin socratic dialogue:
   - Ask ONE question at a time about the requirement
   - After each answer, optionally read a few relevant files to deepen your understanding before asking the next question
   - Challenge vague requirements: "When you say X, do you mean A or B?"
   - Probe for hidden complexity: "What should happen when...?"
   - Explore boundaries: "Should this also handle...?"
   - Validate assumptions: "I'm assuming X - is that correct?"
4. Once you believe you understand the full picture, state in your own words (2-4 sentences) what the user wants built
5. **GATE: Wait for user to confirm your understanding is correct before proceeding to Phase 2**

**Examples** (.NET):
```
User: "Add caching to the API"
Claude: *reads Program.cs, checks existing services*
Claude: "I see you're using ASP.NET Core with a clean architecture layout. When you say caching - are you looking to cache HTTP responses at the middleware level, or cache data at the service/repository layer to reduce database calls?"
```

**Examples** (UE5):
```
User: "Add an inventory system"
Claude: *reads project .uproject, checks existing subsystems*
Claude: "I see this is an action RPG using GameplayAbilities. Before we design the inventory - should items be able to grant gameplay abilities when equipped, or is this purely a data/UI system for carrying items?"
```

---

## Phase 2: Deep Codebase Exploration & Research

**Goal**: Thoroughly understand the existing codebase and research best practices

**Pre-flight Check** (do this first):
1. Detect project type: Look for `.csproj`/`.sln` (.NET), `.uproject`/`.Build.cs` (UE5), or other indicators
2. Assess project maturity using multiple signals:
   - File count (source files only, exclude generated/vendor)
   - Git history depth (`git rev-list --count HEAD` if available)
   - Presence of architecture markers (interfaces, abstractions, DI setup, layered directories)
   - Existing test coverage
3. Calibrate agent mix based on findings:
   - **Greenfield/small** (few source files, shallow git history, minimal abstractions): More research agents, fewer code explorers
   - **Established** (moderate codebase with established patterns and some history): Balanced mix
   - **Mature** (large codebase with deep abstractions, extensive history): More code explorers, targeted research

**Actions**:
1. Launch **3-5 subagents** in parallel using the Agent tool, based on calibration:

   **Code exploration** - use `code-explorer` agents (Sonnet) for codebase analysis:
   - "Map the current project structure, architecture layers, and key abstractions for [project]. Return a list of 5-10 key files."
   - "Find features similar to [feature] and trace their implementation patterns. Return a list of 5-10 key files."
   - "Analyze the data flow and integration points relevant to [feature area]. Return a list of 5-10 key files."

   **Research** - use `research-agent` agents (Sonnet) for best practices:
   - "Research industry best practices and common patterns for [specific task]. Include concrete recommendations."
   - "Research alternative approaches to [specific problem] - compare trade-offs for a greenfield project prioritizing maintainability."

2. Read all key files identified by agents to build deep understanding
3. Synthesize findings: validate that your Phase 1 understanding holds up against what you've found in the codebase
4. Present comprehensive summary of:
   - Current architecture and patterns
   - Research findings and best practices
   - Any discrepancies between Phase 1 understanding and codebase reality

---

## Phase 3: Clarifying Questions (Post-Exploration)

**Goal**: Resolve deeper ambiguities revealed by thorough exploration

**CRITICAL**: This is distinct from Phase 1. Phase 1 clarified *what the user wants to build* — requirements and intent. Phase 3 clarifies *what the codebase reveals about how to build it* — knock-on effects, data flow implications, architectural constraints, and system interactions the user likely didn't anticipate when they stated their goal. These answers are the inputs Phase 4 needs to design the right solution.

**Actions**:
1. Launch `code-explorer` subagents to trace specific concerns discovered during Phase 2. Give each agent a focused goal:
   - "Trace all systems that would be impacted if we [proposed change]. List every caller, subscriber, and downstream dependency."
   - "Map the complete data flow for [specific process]. What are all the knock-on effects if we change [specific thing]?"
   - "Identify edge cases and architectural constraints in [area] that could affect [proposed feature]."
   - Example (UE5): "If we change how this delegate fires, what are ALL the subscribers and their side effects?"
   - Example (.NET): "If we change this service interface, what are all the consumers and what breaks?"

2. Synthesize the subagent findings yourself (use your reasoning to connect the dots across all agents) and present to user:
   - Unintended side effects discovered
   - Architectural constraints that affect the design
   - Questions about scope boundaries
   - Backward compatibility concerns
   - Performance implications

3. **Present questions in an organized list and wait for answers**
4. **GATE: User confirms all ambiguities are resolved before proceeding**

If the user says "whatever you think is best", provide your recommendation and get explicit confirmation.

---

## Phase 4: Architecture Design (MOST IMPORTANT PHASE)

**Goal**: Design a clean, maintainable, KISS and SOLID architecture for the feature

**Actions**:
1. Launch **3–7 `code-architect` agents** (Opus) in parallel (default 3–5, use 6–7 for truly complex or high-risk work).
**CRITICAL**: Assign each agent a specific, different architectural lens to commit to. Without explicit lenses, agents converge on the same design.

   **Pick lenses that actually fit the task and codebase.**

   Always include a baseline “Clean-slate ideal” architect. Then choose 2–6 more lenses based on where complexity and risk live (replication needs, authority boundaries, lifetime/ownership, editor vs runtime, data-driven requirements, performance budgets, and plugin/module layout, etc). All designs should still respect existing project conventions and “clean architecture” style where appropriate. (examples — choose a task-relevant subset):
   - Minimal-change / Integrate-with-existing: extend the current pattern (existing Subsystems, Managers, Components, GAS, SaveGame, etc.); smallest diff; lowest regression risk.
	- Gameplay Framework placement: decide where it lives in UE’s framework: GameMode/GameState/PlayerState/PlayerController/Pawn/ActorComponent; focus on correct ownership, lifetime, and authority.
	- Subsystem-first: implement as UGameInstanceSubsystem, UWorldSubsystem, or UEngineSubsystem with clean lifecycle; good for global services, registries, orchestration.
	- Component-driven composition: represent feature as UActorComponent/USceneComponent (and optionally interfaces) to avoid inheritance tangles; focus on modular attachable behavior.
	- GAS-first (if applicable): model using Gameplay Ability System (Abilities, Effects, Attributes, Tags); replicate/predict correctly; lean on GAS patterns rather than custom state machines.
	- Replication & authority-first: architecture led by networking (RPCs, RepNotifies, relevancy, dormancy, prediction); define server-authoritative state and client presentation boundaries.
	- Data-driven assets-first: use UDataAsset, UPrimaryDataAsset, DataTable, config/INI, gameplay tags; focus on designers authoring content and hot iteration.
	- Save/Load & persistence-first: architecture led by USaveGame, snapshotting, versioning, determinism; handle world partition implications if relevant.
	- Performance & memory-first: avoid tick abuse; choose data layouts; object lifetimes; pooling; async loading; profiling hooks; minimize UObject churn.
	- Editor/tooling-first (if applicable): split runtime module/editor module; details panel customization; asset actions; commandlets; avoid runtime dependencies on editor-only APIs.

   Each agent prompt **must include** the following context (adapt wording to the actual task):
   - **What to build**: The confirmed requirements from Phase 1 — what the feature does, its scope, and any user-specified constraints or preferences
   - **Architectural approach to explore**: The specific pattern/approach this agent should commit to
   - **Project structure overview**: A brief summary of the project layout, tech stack, and key architectural patterns discovered in Phase 2 (e.g., "This is a UE5 action RPG plugin using GameplayAbilities. Core gameplay in Source/MyFeature/, subsystems in Source/MyFeature/Subsystems/, components in Source/MyFeature/Components/.")
   - **Key files to start from**: The 5-10 most relevant files identified in Phase 2. Frame these as starting points, not exhaustive context — e.g., "Start by reading these files to understand the current architecture, then explore further as needed: [file list]"
   - **Important constraints or quirks**: Any non-obvious architectural constraints, technical debt, or codebase quirks discovered in Phases 2-3 that would affect the design (e.g., "The current event system uses a custom pub/sub implementation in src/Events/ — any new feature should integrate with it, not replace it")

   Provide the landscape, not the destination — let each agent form its own architectural judgments from the codebase.

   Example prompt structure (adapt to the actual task):
   ```
   Design this feature using the **Component-driven composition** approach.

   **What to build**: [2-4 sentence summary of confirmed requirements from Phase 1]

   **Project context**: [Brief tech stack and structure summary from Phase 2]. Key files to start from (explore further as needed):
   - Source/MyPlugin/Weapons/BaseWeapon.h — current weapon actor pattern
   - Source/MyPlugin/Components/CombatComponent.h — combat component interface
   - Source/MyPlugin/Subsystems/InventorySubsystem.h — existing subsystem pattern
   - [etc.]

   **Constraints**: [Any important quirks, technical debt, or integration points from Phases 2-3]

   Commit fully to making this approach work well.
   ```

   Be pragmatic about which approaches to explore - pick approaches that genuinely make sense for this specific task. All should lean toward clean architecture and SOLID.

2. Review all returned approaches yourself (synthesize across all designs) and form your recommendation:
   - Start by comparing the **Elevator Pitch** and **Trade-offs & Limitations** sections from each agent — these give you the quickest cross-comparison
   - Which approach best serves the long-term health of the codebase?
   - Which approach best follows SOLID principles?
   - What are the concrete trade-offs? Pay special attention to each agent's self-reported limitations — an approach that honestly surfaces its costs is more trustworthy than one that only advocates.
   - **SOLID sanity check**: For each approach, explicitly identify any SOLID violations or tensions in the design. Flag designs that claim SOLID compliance but have structural issues (e.g., a "strategy pattern" design where the strategies still require modifying a central switch statement).

3. Present to user: approaches, trade-offs, SOLID assessment for each, and **your strong recommendation with reasoning**
4. **GATE: Ask user which approach they prefer**

5. Once approved, produce an **architecture plan file** saved to `.claude/plans/<feature-name>.md` (use a descriptive kebab-case filename, e.g., `inventory-system.md`, `api-caching-layer.md`):

   The plan file should contain:
   - **Summary**: What is being built and why (2-3 sentences)
   - **Architecture**: Overall structure, component responsibilities, key interfaces, data flow
   - **Constraints**: Technical constraints, requirements that must be met, SOLID principles applied
   - **Test Strategy**: What to test, testing approach (unit, integration, etc.), key test scenarios, and where test files should live following project conventions
   - **Implementation Steps**: Numbered semantic steps, each with:
     - Description of what to build
     - Key files to create or modify
     - Complexity estimate: `[SIMPLE]`, `[MODERATE]`, or `[COMPLEX]`
     - Status checkbox: `[ ]` (unchecked) - updated to `[x]` during implementation
   - Implementation steps MUST include dedicated test implementation step(s) — tests are not optional
   - **Code Snippets** (selective): Include snippets only for usage examples showing how the feature should be consumed, key data type structures, or interface contracts. Reserve the full implementation for the implementation phase — the plan provides direction, not the code itself.

   Steps should be user-story sized, not granular tasks. Example:
   - Good: "Implement the inventory component with item data asset integration `[MODERATE]`"
   - Bad: "Create UInventoryComponent header" + "Create item data asset class" + "Register with subsystem" (too granular - these are one step)

   **Complexity budget drives implementation strategy**:
   - **SIMPLE** steps: Done inline in main conversation
   - **MODERATE** steps: Sequential subagent with focused context
   - **COMPLEX** steps: Isolated subagent with thorough context

   The plan should be detailed enough to give suitable context if the conversation is compacted and conversational context is lost. It should prioritize high level design, architecture and decisions over granular code snippets. 

---

## Phase 5: Implementation

**Start only after the user approves the architecture.**

**Goal**: Build the feature following the approved architecture

**Actions**:
1. Read the plan file from `.claude/plans/`
2. Present implementation strategy to user based on the complexity estimates in the plan:
   - For tasks with mostly SIMPLE steps: "I'll implement these directly in our conversation - they're straightforward"
   - For tasks with MODERATE/COMPLEX steps: "I recommend using focused subagents for steps X, Y, Z to keep context clean. Steps A, B are simple enough to do directly."
   - **Ask user for their preference** (inline vs subagent, or mixed)
3. Implement following the plan, using the chosen strategy:
   - Follow codebase conventions strictly
   - Follow SOLID principles at all times
   - Write clean, self-documenting code
   - Comments only where logic is non-obvious
   - Implement tests as specified in the plan's test strategy — tests are a required implementation step, not an afterthought
   - After completing each step, update its checkbox in the plan file from `[ ]` to `[x]` (checkpoint mechanism - if context is compacted or session restarts, the plan file shows exactly where you left off)
4. Run build/compile/tests as appropriate:
   - For larger changes: build and run tests incrementally after each step
   - For smaller changes: build and run tests after implementation completes
   - If tests fail, fix the implementation before proceeding to the next step
5. After implementation (or after each complex subagent task), launch the `doc-updater` agent to update CLAUDE.md and README.md as needed

**Implementation subagent guidelines** (when using subagents):
- Use the Agent tool with `subagent_type: general-purpose` (these need full tool access including Edit, Write, Bash)
- Set the `model` parameter to `sonnet` for SIMPLE steps, `opus` for MODERATE/COMPLEX steps
- Each subagent prompt must include:
  1. The plan file path so it can read the architecture context
  2. Which specific step(s) to implement (quote the step from the plan)
  3. Key file paths it needs to read for context
  4. Instruction: "Read the plan file and the listed files to understand the architecture. Implement the specified step following SOLID principles and existing codebase conventions. Derive all implementation from the codebase patterns and the architecture plan."
- Run subagents sequentially by default for visibility, and to avoid clashing changes causing build errors. For independent steps with no shared state, the user may opt for parallel execution.
- Each subagent should build/compile after its step if the project supports incremental builds

**Error recovery**:
- If a build fails: diagnose the error, fix in context, and retry before moving to the next step
- If a subagent produces incorrect output: review what went wrong, provide corrected context, and rerun the step
- If the user wants to revisit an earlier phase (e.g., architecture needs rethinking): update the plan file to reflect the change, uncheck affected steps, and resume from the appropriate phase
- If context is compacted or session restarts: read the plan file to determine which steps are complete and resume from the first unchecked step

---

## Phase 6: Quality Review

**Goal**: Ensure code is clean, maintainable, SOLID, and functionally correct

**Actions**:
1. First, determine the review scope: run `git diff` (or `git diff --staged` if changes are staged) to get the list of changed files. Include this file list and a summary of what was built (from the plan file) in each review agent's prompt. Instruct each agent to focus on new/modified code only.

2. Verify tests pass: run the project's test suite. If tests fail, fix before proceeding with review.

3. **Two-tier review approach** — scale review depth to task complexity:

   **Tier 1 (always run)** — launch these agents in parallel:

   | Agent (subagent_type) | Model | Focus |
   |-------|-------|-------|
   | correctness-reviewer | opus | Bugs, logic errors, null handling, race conditions, security vulnerabilities |
   | conventions-reviewer | sonnet | CLAUDE.md adherence, project patterns, naming conventions, structure |

   Plus **MANDATORY specialist agents** based on project type (detected in Phase 2 pre-flight). These run **regardless of task complexity** — even simple tasks benefit from their domain expertise:
   - If `.csproj`/`.sln` detected: launch `dotnet-specialist` (Opus)
   - If `.uproject`/`.Build.cs` detected: **ALWAYS launch all three UE5 specialists** in parallel, even for simple tasks. UE5 has pervasive footguns (GC, replication, lifecycle) that generic reviewers cannot catch:
     - `ue5-memory-safety` (Opus) — UPROPERTY, GC, pointer lifetime, asset loading
     - `ue5-architecture` (Sonnet) — class responsibilities, subsystems/components, module/plugin structure
     - `ue5-runtime` (Opus) — replication, delegates, performance, animation, UI lifecycle, level streaming
   - **This is NOT optional. These specialists are NOT part of the tier system — they run unconditionally when the project type matches.**

   **Tier 2 (for medium/complex tasks, or on user request)** — launch these agents in parallel:

   | Agent (subagent_type) | Model | Focus |
   |-------|-------|-------|
   | solid-reviewer | opus | All five SOLID principles — SRP, OCP, LSP, ISP, DIP |
   | code-quality-reviewer | sonnet | DRY, YAGNI, KISS — duplication, unnecessary code, over-engineering |
   | readability-reviewer | sonnet | Naming quality, abstraction level mixing, cognitive complexity, code clarity |
   | error-handling-reviewer | sonnet | Error propagation design, exception hierarchy, failure modes, swallowed errors |

   For simple tasks, ask the user if they want the full SOLID review (Tier 2) or just the essentials (Tier 1).

4. Consolidate all agent findings yourself (deduplicate and prioritize across all agents) and identify highest severity issues
5. **Present findings to user and ask what they want to do**:
   - Fix now
   - Fix later
   - Proceed as-is
6. Address issues based on user decision

**If review reveals fundamental architecture problems** (not just code-level fixes): present the architectural concern to the user and offer to iterate — return to Phase 4 to redesign the affected portion rather than patching over a flawed foundation.

---

## Phase 7: Summary

**Goal**: Document what was accomplished

**Actions**:
1. Mark all todos complete
2. Ensure plan file in `.claude/plans/` is fully updated with completion status
3. Run doc-updater agent one final time to ensure CLAUDE.md and README.md are current
4. Summarize:
   - What was built
   - Key architectural decisions made
   - Files created/modified
   - Tests added and their coverage
   - SOLID principles applied
   - Suggested next steps

---
