---
description: Creating materials, material instances, or organizing materials in Unreal Engine
---

# UE5 Materials

Best practices for material creation and organization in Unreal Engine 5.

## Naming Convention

| Prefix | Asset Type |
|--------|------------|
| M_ | Material |
| MI_ | Material Instance |
| MF_ | Material Function |
| MPC_ | Material Parameter Collection |

Examples: `M_Rock_Master`, `MI_Rock_Mossy`, `MF_WorldAlignedTexture`

## Folder Organization

```
Content/
└── ProjectName/
    └── MaterialLibrary/        # Shared/global materials
        ├── Master/             # Master materials
        ├── Functions/          # Material functions
        ├── Instances/          # Common instances
        └── ParameterCollections/
```

## Master Material Design

Create versatile master materials with static switches:

```
M_Environment_Master
├── [Switch] Use Normal Map
├── [Switch] Use Roughness Map
├── [Switch] Use Metallic Map
├── [Switch] Enable Parallax
├── [Switch] Enable Detail Textures
└── Parameters...
```

**Static switches compile out unused features** - no runtime cost.

## Parameter Organization

Use numbered prefixes for consistent parameter ordering:

| Prefix | Category |
|--------|----------|
| 00 | Base Color |
| 01 | Normal |
| 02 | Roughness |
| 03 | Metallic |
| 04 | Emissive |
| 05 | Tiling/UV |
| 06 | Detail |
| 07 | Special |

Example parameter names:
- `00_BaseColor`
- `01_NormalIntensity`
- `02_RoughnessMin`
- `02_RoughnessMax`

## Material Parameter Collections (MPCs)

Global parameters accessible by any material:

```cpp
// In C++ or Blueprint
UMaterialParameterCollection* MPC = LoadObject<UMaterialParameterCollection>(...);
UKismetMaterialLibrary::SetScalarParameterValue(World, MPC, "GlobalWetness", 0.5f);
```

| Rule | Details |
|------|---------|
| Max 2 MPCs per material | Performance limit |
| Use for global effects | Weather, time of day, etc. |
| Avoid per-object data | Use Material Instances instead |

## Material Instances

**Always use Material Instances, not material copies**

```
M_Character_Master          # Master material
├── MI_Character_Player     # Player instance
├── MI_Character_Enemy_01   # Enemy variant
└── MI_Character_Enemy_02   # Enemy variant
```

Benefits:
- Shared shader compilation
- Easy parameter tweaking
- Reduced memory usage

## Material Functions

Reusable node groups:

```
MF_WorldAlignedTexture     # Common triplanar projection
MF_HeightBlend             # Landscape layer blending
MF_Fresnel_Custom          # Custom fresnel calculation
```

## Best Practices

| Practice | Reason |
|----------|--------|
| Use Material Instances | Not duplicate materials |
| Static switches over dynamic | Compiles out unused code |
| Material Functions for reuse | Maintainable node graphs |
| Limit MPCs to 2 per material | GPU performance |
| Numbered parameter groups | Consistent UI ordering |

## Anti-Patterns

| Avoid | Why |
|-------|-----|
| Over-featured master materials | Shader permutation bloat |
| Copying materials for variants | Memory waste |
| Too many dynamic switches | Runtime cost |
| Excessive texture samples | Performance |

## Performance Tips

- Use texture packing (ORM)
- Limit instruction count
- Use LOD for material complexity
- Profile with Shader Complexity view

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/instanced-materials-in-unreal-engine
