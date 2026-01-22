---
description: Creating or editing Unreal Engine Blueprints, Blueprint variables, or Blueprint functions
---

# UE5 Blueprint Best Practices

Guidelines for clean, maintainable Blueprint code.

## Zero Tolerance Policy

**Zero warnings, zero errors** - Fix all Blueprint compilation issues before committing.

## Naming Conventions

### Variables

| Rule | Example |
|------|---------|
| PascalCase | `PlayerHealth`, `MaxAmmo` |
| Boolean prefix `b` | `bIsAlive`, `bCanJump`, `bHasWeapon` |
| No abbreviations | `CurrentHealthPoints` not `CurHP` |

### Functions

| Type | Naming | Example |
|------|--------|---------|
| Actions | Verb | `FireWeapon`, `TakeDamage` |
| Events | On prefix | `OnDeath`, `OnItemPickup` |
| Queries | Is/Has/Can | `IsAlive`, `HasAmmo`, `CanFire` |

### RPC Functions

| Prefix | Direction |
|--------|-----------|
| Server_ | Client → Server |
| Client_ | Server → Client |
| Multicast_ | Server → All Clients |

## Function Guidelines

- **50-node maximum** per function
- **All functions must have return nodes**
- Group related nodes with **comment blocks**
- **Align wires, not nodes** for readability

## Graph Organization

```
[Comment: Input Handling]
┌─────────────────────────┐
│  Input → Validate →     │
│  Process → Output       │
└─────────────────────────┘

[Comment: Combat Logic]
┌─────────────────────────┐
│  Damage Calculation     │
│  → Apply → Notify       │
└─────────────────────────┘
```

## Performance

| Avoid | Use Instead |
|-------|-------------|
| Complex Tick logic | Timers or events |
| Many Cast nodes | Interfaces or cached refs |
| String operations in Tick | Pre-computed values |
| Deep nesting (>3 levels) | Extracted functions |

## When to Use C++

Move to C++ when:
- Heavy per-frame calculations
- Complex math operations
- Large data structure manipulation
- Performance-critical systems
- Deep inheritance hierarchies

## Best Practices Checklist

- [ ] All variables have categories assigned
- [ ] All functions have descriptions/tooltips
- [ ] Event Graph is organized with comments
- [ ] No unconnected nodes (reroute or delete)
- [ ] Consistent execution flow (left to right)
- [ ] Local variables used appropriately
- [ ] No duplicate code (use functions/macros)

## Variable Categories

Organize with numbered prefixes for consistent ordering:

```
00|Core
01|Combat
02|Movement
03|UI
04|Audio
05|Debug
```

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/blueprint-best-practices-in-unreal-engine
