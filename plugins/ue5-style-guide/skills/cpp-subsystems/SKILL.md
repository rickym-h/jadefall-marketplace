---
description: Creating UE5 subsystems, singletons, or global manager classes
---

# UE5 C++ Subsystems

Subsystems provide a clean pattern for creating managers and global systems without subclassing engine classes.

## Subsystem Types

| Type | Parent | Lifecycle | Access |
|------|--------|-----------|--------|
| UEngineSubsystem | GEngine | Engine lifetime | `GEngine->GetEngineSubsystem<T>()` |
| UEditorSubsystem | GEditor | Editor lifetime | Editor only, not in packaged games |
| UGameInstanceSubsystem | UGameInstance | Game session | `GetGameInstance()->GetSubsystem<T>()` |
| UWorldSubsystem | UWorld | World/Level | `GetWorld()->GetSubsystem<T>()` |
| ULocalPlayerSubsystem | ULocalPlayer | Per local player | `LocalPlayer->GetSubsystem<T>()` |

## Creating a Subsystem

```cpp
// SaveGameSubsystem.h
#pragma once

#include "Subsystems/GameInstanceSubsystem.h"
#include "SaveGameSubsystem.generated.h"

UCLASS()
class MYGAME_API USaveGameSubsystem : public UGameInstanceSubsystem
{
    GENERATED_BODY()

public:
    // Called when subsystem is created
    virtual void Initialize(FSubsystemCollectionBase& Collection) override;

    // Called when subsystem is destroyed
    virtual void Deinitialize() override;

    // Public API
    UFUNCTION(BlueprintCallable, Category = "Save")
    void SaveGame();

    UFUNCTION(BlueprintCallable, Category = "Save")
    void LoadGame();

private:
    UPROPERTY()
    USaveGame* CurrentSaveGame;
};
```

## Accessing Subsystems

```cpp
// From any UObject with world context
if (UGameInstance* GI = GetGameInstance())
{
    USaveGameSubsystem* SaveSystem = GI->GetSubsystem<USaveGameSubsystem>();
    SaveSystem->SaveGame();
}

// From Actor
USaveGameSubsystem* SaveSystem = GetGameInstance()->GetSubsystem<USaveGameSubsystem>();

// World subsystem
UMyWorldSubsystem* WorldSub = GetWorld()->GetSubsystem<UMyWorldSubsystem>();

// Local player subsystem
UMyLocalPlayerSubsystem* LPSub = LocalPlayer->GetSubsystem<UMyLocalPlayerSubsystem>();
```

## Benefits Over Singletons

| Subsystems | Traditional Singletons |
|------------|----------------------|
| Auto-managed lifecycle | Manual creation/destruction |
| Proper GC integration | Memory leak potential |
| Built-in Blueprint/Python exposure | Requires manual exposure |
| Avoids subclassing engine classes | Often requires engine subclassing |
| Modular/plugin-friendly | Tight coupling |

## Best Practices

| Practice | Reason |
|----------|--------|
| Use GameInstanceSubsystem for session data | Persists across levels |
| Use WorldSubsystem for level-specific managers | Cleaned up on level change |
| Engine subsystems init once | Not per-PIE instance |
| No Blueprint subclasses | Use UDeveloperSettings + DataTables for config |
| Editor subsystems are editor-only | Cannot use in packaged games |

## Designer Configuration

Instead of Blueprint subclasses, use:

```cpp
// For project settings
UCLASS(config=Game, defaultconfig, meta=(DisplayName="My Game Settings"))
class UMyGameSettings : public UDeveloperSettings
{
    GENERATED_BODY()

public:
    UPROPERTY(Config, EditAnywhere, Category = "Gameplay")
    float DefaultDifficulty = 1.0f;
};

// Access in subsystem
const UMyGameSettings* Settings = GetDefault<UMyGameSettings>();
```

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/programming-subsystems-in-unreal-engine
