---
description: Importing textures, configuring texture settings, or optimizing textures in Unreal Engine
---

# UE5 Textures

Best practices for texture assets in Unreal Engine 5.

## Naming Convention

```
T_BaseAssetName_MapType
```

| Suffix | Map Type |
|--------|----------|
| _D | Diffuse/Base Color |
| _N | Normal Map |
| _R | Roughness |
| _M | Metallic |
| _E | Emissive |
| _A | Alpha/Opacity |
| _O | Ambient Occlusion |
| _ORM | Packed AO/Roughness/Metallic |
| _H | Height/Displacement |

Examples: `T_Rock_D`, `T_Rock_N`, `T_Rock_ORM`

## Resolution Requirements

| Rule | Details |
|------|---------|
| Power of 2 | 256, 512, 1024, 2048, 4096, 8192 |
| Maximum | 8192x8192 |
| UI Exception | UI textures can be non-power-of-2 |

## Compression Settings

| Format | Use Case |
|--------|----------|
| BC1/DXT1 | RGB, no alpha (smallest) |
| BC3/DXT5 | RGBA with alpha |
| BC5 | Normal maps (2-channel) |
| BC7 | High quality RGBA |
| ASTC | Mobile platforms |
| ETC2 | Mobile fallback |

## sRGB Settings

| Texture Type | sRGB |
|-------------|------|
| Base Color/Diffuse | ON |
| Normal Map | OFF |
| Roughness | OFF |
| Metallic | OFF |
| AO | OFF |
| Emissive | ON |
| Masks | OFF |

**Rule: sRGB OFF for any non-color data**

## Texture Packing

Combine grayscale maps into single texture channels:

```
ORM Texture (3 maps in 1):
  R = Ambient Occlusion
  G = Roughness
  B = Metallic
  A = (unused or mask)
```

Benefits:
- Fewer texture samples
- Reduced memory
- Better performance

## Texture Groups

Assign appropriate texture groups for LOD behavior:

| Group | Use Case |
|-------|----------|
| World | Environment textures |
| Character | Character textures |
| Weapon | Weapon textures |
| UI | Interface textures |
| Effects | VFX textures |

## Best Practices

| Practice | Reason |
|----------|--------|
| Enable mipmaps | Prevents aliasing at distance |
| Consistent texel density | Visual consistency |
| Pack grayscale maps | Performance |
| Use BC5 for normals | Quality preservation |
| Appropriate max size | Memory optimization |

## Import Settings Checklist

- [ ] Correct compression format selected
- [ ] sRGB set correctly for texture type
- [ ] Mipmap generation enabled
- [ ] Power of 2 dimensions (or UI exception)
- [ ] Appropriate texture group assigned
- [ ] Normal map detected and configured

## Mobile Considerations

| Platform | Format |
|----------|--------|
| iOS | ASTC |
| Android | ASTC or ETC2 |
| Fallback | ETC2 |

Set platform-specific overrides in texture settings for mobile builds.

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/texture-format-support-and-settings-in-unreal-engine
