---
description: Importing meshes, setting up collision, or configuring LODs in Unreal Engine
---

# UE5 Static Meshes

Best practices for static mesh assets in Unreal Engine 5.

## Naming Convention

```
SM_BaseAssetName_Variant
```

Examples: `SM_Rock_01`, `SM_Chair_Wooden`, `SM_Door_Metal_Large`

## Import Requirements

| Requirement | Details |
|-------------|---------|
| UVs | All meshes must have UVs |
| Lightmap UVs | Non-overlapping for baked lighting |
| Scale | Correct at import (1 unit = 1 cm) |
| Orientation | Z-up, facing +X |

## Collision Setup

### Collision Types

| Type | Use Case |
|------|----------|
| Simple | Preferred for performance (convex shapes) |
| Complex | Only when simple won't work (accurate hit detection) |

### DCC Tool Naming (FBX Import)

| Prefix | Collision Type |
|--------|---------------|
| UCX_ | Convex hull |
| UBX_ | Box |
| USP_ | Sphere |
| UCP_ | Capsule |

```
# In your DCC tool, name collision meshes:
UCX_SM_Rock_01      # Convex collision for SM_Rock_01
UBX_SM_Crate_01     # Box collision for SM_Crate_01
```

### Import Settings

- Enable **Generate Missing Collisions** for automatic simple collision
- Use **Convex Decomposition** for complex shapes needing multiple convex hulls

## LOD Configuration

### LOD Groups

Use LOD Groups for automatic LOD generation:
- LargeWorld
- SmallWorld
- Diorama
- Custom project-specific groups

### LOD Settings

| Setting | Description |
|---------|-------------|
| Screen Size | LOD switches based on screen size, not distance |
| Reduction | Percentage of triangles to keep |
| Min LOD | Minimum LOD to use |

## Nanite (UE5)

For high-poly meshes, enable Nanite:

| Benefit | Description |
|---------|-------------|
| Automatic LOD | Built-in virtualized geometry |
| No manual LOD setup | Handles detail streaming |
| Massive poly counts | Millions of triangles efficiently |

### Nanite Limitations

- No deformation/skeletal meshes
- No translucent materials
- No vertex animation

## Best Practices

| Practice | Reason |
|----------|--------|
| Power of 2 texture sizes | GPU optimization |
| Consistent texel density | Visual quality |
| Clean topology | Better LOD generation |
| Proper pivot placement | Easier placement in editor |
| No ngons | Consistent triangulation |

## Performance Tips

- Prefer simple collision over complex
- Use instancing for repeated meshes
- Merge small static meshes where possible
- Enable Nanite for high-detail meshes
- Set appropriate LOD screen sizes

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/static-meshes-in-unreal-engine
