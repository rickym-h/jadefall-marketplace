---
name: ue5-structural-decisions
description: UE5 framework class placement, subsystem vs component decisions, data ownership, replication, RPC routing, and module structure. Use when deciding where logic or data should live in UE5 (GameMode vs GameState vs PlayerController vs PlayerState vs Pawn), choosing between subsystem and component, designing replication strategy, structuring modules/plugins, or reviewing architectural placement of inventory, quests, teams, health, scoring, matchmaking, or save systems.
---

# UE5 Structural Decision Reference

Decision criteria for where logic, data, and systems should live in UE5. Use this when designing new features or reviewing architectural placement.

---

## Framework Class Placement

### The Four Governing Questions

Evaluate every piece of logic or data against these axes:

**1. Who should see it?**
- Server only → GameMode
- All clients (shared game state) → GameState
- Server + owning client only → PlayerController
- All clients, per-player → PlayerState
- Local process only (not replicated) → GameInstance / Subsystem

**2. Does it survive respawn?**
- Must survive → PlayerState, PlayerController, GameInstance, Subsystems
- Does not survive → Pawn/Character (destroyed and replaced on death)

**3. Does it survive map travel?**
- Hard travel (OpenLevel) → GameInstance / GameInstanceSubsystem only
- Seamless travel → PlayerState (with `CopyProperties()`), PlayerController (conditionally), GameInstance
- Per-level only → GameState, WorldSubsystem

**4. Is it server-authoritative?**
- Yes → Replicated framework class (GameState, PlayerState, GameMode)
- No → Local GameInstance, LocalPlayerSubsystem

### Class Responsibilities

**UGameInstance** — App-level singleton, survives all map transitions. Persistent state, sessions, global managers. NOT for: match-specific rules, per-player data, anything that should reset on map change. NOT replicated — server and each client have independent instances.

**AGameMode** — Server-only, one per match. Match rules, scoring, spawning, player admission (Login/PostLogin), class selection. NOT for: any data clients need to read (GameMode does not exist on clients).

**AGameState** — Replicated to all clients, one per match. Shared match data (score, timer, teams), PlayerState list, match phase. NOT for: per-player state (use PlayerState), server-only logic (use GameMode).

**APlayerController** — One per human player (server + owning client). Input, camera, HUD ownership, client-to-server RPCs, pawn possession. Good location for "private to this player" components (inventory, quest progress). In seamless travel, the engine attempts to preserve PlayerControllers; treat as "usually yes," but don't store irreplaceable state here unless you control the travel path. NOT for: visual representation (Pawn), persistent identity (PlayerState), match rules.

**APlayerState** — Replicated to all clients, one per player, survives respawn. Player identity, visible stats, team assignment, persistent-within-match data. NOT for: input, camera, UI, transient pawn state. Note: if adding components (e.g., ASC), raise `NetUpdateFrequency` or enable Adaptive Network Update Frequency.

**APawn / ACharacter** — Physical world representation. Movement, collision, visuals, animations, abilities/interactions. State here resets on respawn. NOT for: input routing (PlayerController), identity (PlayerState), match rules.

### Data Placement Flowchart

Work through in order:

1. **Must survive process close?** → USaveGame object (all framework classes are in-memory only)
2. **Must survive hard map travel?** → GameInstance / GameInstanceSubsystem
3. **Must all clients see it?**
   - Shared game state → GameState
   - Per-player data → PlayerState
4. **Only owning client + server?** → PlayerController component
5. **Must survive pawn respawn?** → PlayerState (if public) or PlayerController (if private)
6. **Resets on respawn?** → Pawn/Character component
7. **Server-only rules logic?** → GameMode

### Quick Reference Table

| Question | GameMode | GameState | PlayerController | PlayerState | Pawn | GameInstance |
|---|---|---|---|---|---|---|
| Exists on clients? | No | Yes | Owning only | Yes | Yes | Yes (independent) |
| Replicated? | N/A | Yes | Partial | Yes | Yes (if set up; often mixed owner-only + relevancy-limited) | No |
| Survives respawn? | N/A | Yes | Yes | Yes | No | Yes |
| Survives seamless travel? | No | No | Conditional | Yes (CopyProperties) | No | Yes |
| Survives hard travel? | No | No | No | No | No | Yes |

---

## Subsystem vs Component vs Manager

### Decision Rules

**Use UActorComponent if:**
- Behavior needs to compose onto multiple actor types (inventory on player, chest, vendor — same component)
- Data needs to replicate (components can replicate as part of their owning replicated Actor, but you must enable it — `SetIsReplicatedByDefault(true)` in the constructor, and replicate properties/RPCs explicitly; subsystems never replicate)
- Per-actor state differs between instances (each actor's own health, equipment, abilities)
- Designers need Blueprint authoring of per-actor behavior

**Use USubsystem if:**
- Singleton-scoped — one instance per parent scope (game, world, player)
- Does not need to replicate (subsystems are non-replicated by design)
- Service/coordinator role — manages actors and components but is not itself an actor
- Automatic lifecycle without hand-written singleton patterns

**Use a Manager Actor (AActor subclass) if:**
- Needs world placement or physical presence
- Needs to replicate server state to clients and no existing framework class fits
- Prefer making it a GameState/GameMode component injected via GameFeatureAction over a freestanding actor

**Use a plain UObject / UDataAsset if:**
- Data container with no lifecycle, replication, or world context requirements (item definitions, quest definitions, config data)

### Key constraint: Subsystems never replicate

This is the single most important factor. If a system needs clients to see its state, it cannot be a subsystem alone. Use a subsystem as a coordinator/service layer, and put replicated state on framework actors or their components.

---

## Subsystem Tier Selection

| Tier | Created | Destroyed | Survives Map Travel | Count | Use Case |
|---|---|---|---|---|---|
| UEngineSubsystem | Engine startup | Engine shutdown | Yes (always alive) | 1 | Editor tooling, engine-level resources |
| UGameInstanceSubsystem | GameInstance created | GameInstance destroyed | Yes | 1 per instance | Cross-level services: save/load, matchmaking, online sessions, achievements |
| UWorldSubsystem | World created | World destroyed | No | 1 per world | Level-scoped: AI budgets, spatial caches, level events, dialogue coordination |
| ULocalPlayerSubsystem | Local player joins | Local player leaves | Yes | 1 per local player | Local-only: input remapping, UI preferences, audio settings |

### Pitfalls

- **GameInstanceSubsystem for per-level state**: It doesn't reset on map load. Stale data persists across levels.
- **WorldSubsystem for cross-level state**: It's destroyed on level unload. Data is lost.
- **LocalPlayerSubsystem confused with PlayerState**: LocalPlayerSubsystem is local-process-only, never replicated. PlayerState is server-authoritative and replicated. Use LocalPlayerSubsystem for local preferences; PlayerState for authoritative game data.
- **WorldSubsystem holding server-authoritative state**: Server's WorldSubsystem and each client's are independent, non-replicated. Use GameState for shared authoritative state. On a listen server, server + local client share a process, which can hide this bug during testing — dedicated server testing will expose it.

---

## GameFeaturePlugin Decisions

**Use a GameFeaturePlugin if:**
- The feature is optional at runtime (DLC, seasonal content, A/B testing, platform-specific)
- The feature can be activated/deactivated without restart
- The feature adds behavior to framework actors without creating compile-time dependencies (injects components via `GameFeatureAction_AddComponents`)
- The feature maps to a distinct "experience" or "game mode" (Lyra pattern)

**Keep it in the main game module if:**
- The system is always present and always active
- Other systems have hard dependencies on it (making it a GFP creates circular loading)
- The team hasn't established Modular Gameplay base classes (`AModularCharacter`, `AModularPlayerController`, etc.) — GFPs require these for component injection
- The feature is small with no reason to load conditionally

### Prerequisite for GFPs

Base classes must derive from Modular counterparts. Retrofitting this late is non-trivial — establish early if you intend to use GFPs.

---

## Common System Placement

| System | Recommended Placement | Rationale |
|---|---|---|
| **Inventory** | UActorComponent on PlayerController | Private to owning player, survives respawn. Use `FFastArraySerializer` for replication. Move to Pawn if AI bots also need inventories. If inventory must be spectated/observed by others, consider PlayerState as the replicated owner instead. |
| **Quest progress** | UActorComponent on PlayerController (private) or PlayerState (visible to party) | Per-player state. Coordination/routing in a UWorldSubsystem. Persistence via GameInstanceSubsystem. Definitions as UPrimaryDataAsset. |
| **Dialogue** | UWorldSubsystem for conversation state; UDataAsset for content | Level-scoped. Persist cross-level state via GameInstanceSubsystem on conversation end. |
| **Save/Load** | UGameInstanceSubsystem as coordinator; USaveGame as data container | Must span level boundaries. Subsystem manages slots, async writes, serialization. |
| **Matchmaking** | UGameInstanceSubsystem wrapping IOnlineSession | Must persist across level loads (lobby → game → results). |
| **Teams** | Team ID on PlayerState; coordination in UWorldSubsystem | All clients need team assignment for UI/friendly fire. Subsystem provides mutation API and event routing. Team metadata on replicated actors in GameState (Lyra pattern). |
| **Player score** | PlayerState | Replicated, survives respawn, all clients see it. |
| **Current health** | Pawn/Character component | Resets on death, visually relevant to that actor. |
| **Match timer/phase** | GameState | All clients need it for HUD. |
| **Spawn logic/waves** | GameMode | Server-only rules. Never on client. |
| **Input bindings** | PlayerController or LocalPlayerSubsystem | Local-only, not authoritative. |

### GAS-Specific: AbilitySystemComponent Placement

- **On PlayerState**: Attributes/Effects persist through respawn. Required for games where death doesn't reset stats. Must raise `NetUpdateFrequency`. Fortnite pattern.
- **On Pawn**: Full reset on death. Simpler lifecycle. Better for games where death means clean slate.
- Source: Dave Ratti (Epic) guidance and GASDocumentation community reference.

---

## Authority + RPC Routing

### Request flow

- Client input/request → Server RPC on PlayerController (or possessed Pawn if appropriate)
- Server broadcasts state → replicated properties on GameState / PlayerState / Pawn, or Multicast RPC sparingly
- Never rely on Multicast RPCs for durable state — late joiners miss them. Use replicated properties for anything that must be correct on join.

### Replication ownership

- Owner-only data: `COND_OwnerOnly` / `bOnlyRelevantToOwner`
- Public per-player data: PlayerState
- Global shared data: GameState
- Server-only data: GameMode (no replication needed)

### Common mistakes

- Sending gameplay-critical state via Multicast instead of replicated properties (late joiners get stale state)
- Client calling Server RPCs on actors it doesn't own (RPC is silently dropped)
- Using `NetMulticast` for visual effects that should be `Unreliable` (reliable multicast can flood the network)

---

## Module + Plugin Structure

### Module boundaries

- Separate Runtime and Editor modules (`MyGame` + `MyGameEditor`). Editor modules depend on Runtime, never the reverse.
- Put shared types, interfaces, and data definitions in a core module (`MyGameCore`). Feature modules depend on Core, not on each other.
- Avoid Blueprint Function Libraries becoming god-modules — split by domain.

### Plugin vs Module vs GFP

- **Module**: Compile-time code boundary within the project. Use for always-loaded systems that need clear dependency control.
- **Plugin**: Reusable across projects, or needs marketplace distribution. Has its own `.uplugin`, can contain multiple modules.
- **GameFeaturePlugin**: Runtime-activatable content/behavior. Use when the feature should be optional, injectable, or experience-driven (see GFP section above).

### Build.cs dependency rules

- Keep dependency graphs acyclic. If A depends on B and B needs something from A, extract the shared interface into Core.
- Use `PublicDependencyModuleNames` only for types exposed in your public headers. Use `PrivateDependencyModuleNames` for everything else.
- `/Public` headers = your module's API surface. `/Private` = implementation details. Never include a `/Private` header from another module.

---

## Anti-Patterns

| Anti-Pattern | Why It Breaks | Fix |
|---|---|---|
| Server-authoritative data in GameInstance | Not replicated — clients never see it | Use GameState or PlayerState |
| Reading data from GameMode on client | GameMode doesn't exist on clients | Route through GameState |
| TMap<PlayerID, Data> in GameState | Duplicates PlayerState's role, bloats replication | Let each PlayerState own its player's data |
| GameInstanceSubsystem for per-level state | Doesn't reset on level load — stale data | Use WorldSubsystem |
| Static singleton manager (`::Get()`) | No lifecycle integration, stale across PIE, GC-unsafe | Use appropriate subsystem tier |
| GFPs without Modular Gameplay base classes | Component injection silently fails | Establish modular base classes first |
| Storing replicated data in subsystems | Subsystems never replicate | Subsystem coordinates; replicated state on framework actors |
