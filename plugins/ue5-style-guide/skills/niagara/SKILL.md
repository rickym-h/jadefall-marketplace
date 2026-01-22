---
description: Creating Niagara particle systems or organizing VFX in Unreal Engine
---

# UE5 Niagara

Best practices for Niagara visual effects in Unreal Engine 5.

## Naming Convention

| Prefix | Asset Type |
|--------|------------|
| NS_ | Niagara System |
| NE_ | Niagara Emitter |
| NM_ | Niagara Module |
| NDI_ | Niagara Data Interface |

Examples: `NS_Explosion_Fire`, `NE_Sparks_Burst`, `NM_ScaleBySpeed`

## Critical Rule

**No spaces in identifiers** - HLSL compatibility requires underscore-separated names.

```
# CORRECT
NS_Fire_Explosion_Large
NE_Smoke_Wispy

# WRONG
NS Fire Explosion Large
NE Smoke Wispy
```

## System Architecture

```
Niagara System (NS_)
├── Emitter 1 (NE_)
│   └── Module Stack
├── Emitter 2 (NE_)
│   └── Module Stack
└── Emitter 3 (NE_)
    └── Module Stack
```

**Systems contain emitters** - emitters cannot be placed in levels alone.

## Module Stack Order

Modules process **top-to-bottom** within each stage:

```
Emitter Update
├── Emitter State
└── Spawn Rate

Particle Spawn
├── Initialize Particle
├── Set Position
└── Set Velocity

Particle Update
├── Apply Forces
├── Update Color
└── Scale By Lifetime

Render
└── Sprite Renderer
```

## Emitter Naming in Multi-Emitter Systems

Use descriptive names within systems:

```
NS_Explosion_Fire
├── Fire_Core           # Central fire burst
├── Fire_Secondary      # Outer flames
├── Smoke_Dark          # Dark smoke plume
├── Smoke_Light         # Lighter dissipating smoke
├── Sparks_Burst        # Initial spark burst
├── Sparks_Trailing     # Lingering sparks
└── Debris_Chunks       # Physical debris
```

## Organization

Use **tags** for asset organization in Niagara browser:

| Tag | Purpose |
|-----|---------|
| Environment | Environmental effects |
| Combat | Weapon/damage effects |
| Character | Character-related VFX |
| UI | Interface effects |
| Ambient | Background/atmosphere |

## Performance

| Practice | Benefit |
|----------|---------|
| GPU simulation | Better performance for large counts |
| Bounded emitters | Culling optimization |
| LOD settings | Distance-based quality |
| Fixed bounds | Avoid recalculation |
| Pooling | Reduce spawn overhead |

## GPU vs CPU Simulation

| GPU Simulation | CPU Simulation |
|----------------|----------------|
| Large particle counts | Complex logic |
| Simple behavior | Collision queries |
| Better scalability | Event handling |
| Distance field collision | Precise physics |

## Best Practices

| Practice | Reason |
|----------|--------|
| Descriptive emitter names | Clarity in complex systems |
| Use inheritance | Share common emitter setups |
| Set explicit bounds | Performance |
| Profile with Niagara Debugger | Identify bottlenecks |
| Use LODs | Quality/performance scaling |

## Common Modules

| Module | Purpose |
|--------|---------|
| Initialize Particle | Set initial state |
| Add Velocity | Movement direction |
| Gravity Force | Physics simulation |
| Drag | Air resistance |
| Scale Color | Color over lifetime |
| Scale Sprite Size | Size over lifetime |
| Curl Noise Force | Organic movement |

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/overview-of-niagara-effects-for-unreal-engine
