---
description: Creating, renaming, or organizing Unreal Engine assets
---

# UE5 Asset Naming Conventions

Follow these naming conventions for all Unreal Engine 5 assets.

## Naming Pattern

```
Prefix_BaseAssetName_Variant_Suffix
```

- **Prefix**: Asset type identifier (required)
- **BaseAssetName**: Descriptive name in PascalCase
- **Variant**: Descriptive name or 2-digit number (01, 02) for variations
- **Suffix**: Additional type info, especially for textures

## Asset Type Prefixes

| Prefix | Asset Type |
|--------|------------|
| BP_ | Blueprint |
| M_ | Material |
| MI_ | Material Instance |
| SM_ | Static Mesh |
| SK_ | Skeletal Mesh |
| T_ | Texture |
| P_ | Particle System (Legacy) |
| S_ | Sound |
| RT_ | Render Target |
| A_ | Animation Sequence |
| ABP_ | Animation Blueprint |
| WBP_ | Widget Blueprint |
| NS_ | Niagara System |
| NE_ | Niagara Emitter |

## Texture Suffixes

| Suffix | Map Type |
|--------|----------|
| _D | Diffuse/Base Color |
| _N | Normal |
| _R | Roughness |
| _M | Metallic |
| _E | Emissive |
| _A | Alpha/Opacity |
| _O | Ambient Occlusion |
| _ORM | Packed AO/Roughness/Metallic |

## Rules

- Use **PascalCase** for all identifiers
- No spaces, Unicode, or special characters
- Valid characters: `[A-Za-z0-9_]+`
- Keep names descriptive but concise

## Examples

```
SM_Rock_01
SM_Rock_Mossy_02
T_Rock_D
T_Rock_N
T_Rock_ORM
M_Rock_Master
MI_Rock_Mossy
BP_PickupItem_Health
WBP_MainMenu
NS_Explosion_Fire
```

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/recommended-asset-naming-conventions-in-unreal-engine-projects
