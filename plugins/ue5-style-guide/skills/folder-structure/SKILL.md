---
description: Creating directories, reorganizing content, or setting up Unreal Engine project structure
---

# UE5 Folder Structure

Organize your Unreal Engine 5 project using feature-based organization.

## Core Principles

- **Feature-based organization** (not type-based)
- **3-4 levels of depth** (avoid >5 levels)
- **Top-level project folder**: `/Content/ProjectName/`

## Recommended Structure

```
Content/
└── ProjectName/
    ├── Core/                    # Critical systems
    │   ├── GameMode/
    │   ├── Character/
    │   └── PlayerController/
    ├── Characters/              # Character assets by type
    │   ├── Player/
    │   └── Enemies/
    ├── Weapons/                 # Weapon feature
    │   ├── Rifle/
    │   └── Pistol/
    ├── Environment/             # Environment assets
    │   ├── Props/
    │   └── Foliage/
    ├── UI/                      # User interface
    │   ├── HUD/
    │   └── Menus/
    ├── Maps/                    # All levels
    │   ├── MainMenu/
    │   └── Gameplay/
    ├── MaterialLibrary/         # Shared/global materials
    ├── Audio/                   # Sound assets
    └── VFX/                     # Visual effects
```

## Special Folders

| Folder | Purpose |
|--------|---------|
| `/Content/ProjectName/Core/` | Critical base classes and systems |
| `/Content/ProjectName/Maps/` | All level files |
| `/Content/ProjectName/MaterialLibrary/` | Shared materials across features |
| `/Content/Developers/` | WIP assets (hidden by default in Content Browser) |

## Best Practices

- **Fix up redirectors** before source control commits
- Use **version control as backup** when reorganizing
- Keep related assets together (mesh + materials + textures)
- Avoid deeply nested structures (>5 levels)
- Use Developer folders for work-in-progress assets

## Anti-Patterns

Avoid type-based organization:
```
# BAD - Don't do this
Content/
├── Meshes/
├── Materials/
├── Textures/
└── Blueprints/
```

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-engine-directory-structure
