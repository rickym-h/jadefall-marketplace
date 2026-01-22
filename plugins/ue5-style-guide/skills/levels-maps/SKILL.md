---
description: Creating levels, organizing worlds, or configuring streaming in Unreal Engine
---

# UE5 Levels & Maps

Best practices for level organization and World Partition in Unreal Engine 5.

## Folder Organization

All maps in a dedicated folder:

```
Content/
└── ProjectName/
    └── Maps/
        ├── MainMenu/
        │   └── L_MainMenu.umap
        ├── Gameplay/
        │   ├── L_Level01.umap
        │   └── L_Level02.umap
        └── Test/
            └── L_TestMap.umap
```

## World Partition (UE5)

**Strongly recommended** - replaces legacy level streaming.

### Benefits

| Feature | Description |
|---------|-------------|
| Grid-based streaming | Automatic cell loading/unloading |
| One-file-per-actor | Better team collaboration |
| Data Layers | Runtime actor organization |
| No manual streaming volumes | Automatic based on distance |

### Setup

1. Create new level with World Partition enabled
2. Configure grid cell size (default: 12800 units)
3. Set up streaming sources

## Data Layers

Organize actors and toggle visibility at runtime:

| Layer Type | Use Case |
|------------|----------|
| Runtime Data Layers | Toggle at runtime (day/night variants) |
| Editor Data Layers | Editor organization only |

```cpp
// Toggle data layer at runtime
UDataLayerSubsystem* DataLayerSubsystem = GetWorld()->GetSubsystem<UDataLayerSubsystem>();
DataLayerSubsystem->SetDataLayerRuntimeState(DataLayer, EDataLayerRuntimeState::Activated);
```

## Streaming Sources

Control what areas load based on:

| Source | Description |
|--------|-------------|
| PlayerController | Default, loads around players |
| Custom Sources | Cameras, vehicles, AI |

```cpp
// Register custom streaming source
GetWorld()->GetWorldPartition()->RegisterStreamingSourceProvider(MyStreamingSource);
```

## One-File-Per-Actor (OFPA)

Enable for team collaboration:

| Benefit | Description |
|---------|-------------|
| Reduced conflicts | Each actor in separate file |
| Parallel work | Multiple team members, same level |
| Better diffs | Smaller, focused changes |

## Quality Checklist

| Check | Description |
|-------|-------------|
| Zero map errors | Run Map Check, fix all issues |
| Zero warnings | Address all warnings |
| Lighting built | Build lighting before distribution |
| No Z-fighting | Fix overlapping geometry |
| Streaming tested | Verify smooth loading |

## Best Practices

| Practice | Reason |
|----------|--------|
| Use World Partition | Modern streaming, collaboration |
| Enable OFPA | Team workflow |
| Set up Data Layers | Runtime organization |
| Configure grid size appropriately | Balance streaming granularity |
| Test streaming on target hardware | Verify performance |

## Legacy Level Streaming

If not using World Partition:

```
Persistent Level
├── Sublevel_Gameplay
├── Sublevel_Lighting
├── Sublevel_Audio
└── Sublevel_Cinematics
```

Use Level Streaming Volumes or Blueprint to control loading.

## Performance Tips

| Tip | Benefit |
|-----|---------|
| Appropriate grid cell size | Balance load frequency vs. memory |
| HLOD for distant objects | Reduced draw calls |
| Proper actor bounds | Accurate culling |
| Streaming source priorities | Load important areas first |

## Common Issues

| Issue | Solution |
|-------|----------|
| Actors not streaming | Check grid placement, bounds |
| Slow loading | Reduce cell size, optimize assets |
| Pop-in | Adjust loading distance, use HLOD |
| Collaboration conflicts | Enable OFPA |

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/world-partition-in-unreal-engine
