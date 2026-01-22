---
description: Creating new UE5 C++ classes, organizing header and source files
---

# UE5 C++ Class Structure

Organize your C++ classes following Unreal Engine conventions.

## Module Folder Structure

```
Source/
└── ModuleName/
    ├── Public/           # Header files (.h)
    │   ├── Components/
    │   ├── Actors/
    │   └── Core/
    ├── Private/          # Source files (.cpp)
    │   ├── Components/
    │   ├── Actors/
    │   └── Core/
    └── ModuleName.Build.cs
```

## File Naming

- **No class prefix in filename**: `Actor.h` not `AActor.h`
- Match filename to class name (without prefix)
- One primary class per file

## Class Declaration

```cpp
// HealthComponent.h
#pragma once

#include "CoreMinimal.h"
#include "Components/ActorComponent.h"
#include "HealthComponent.generated.h"

// Forward declarations (prefer over #includes)
class ABaseCharacter;
class UDamageType;

UCLASS(ClassGroup=(Custom), meta=(BlueprintSpawnableComponent))
class MYGAME_API UHealthComponent : public UActorComponent
{
    GENERATED_BODY()  // Required in all UCLASS declarations

public:
    UHealthComponent();

    // Public interface
    UFUNCTION(BlueprintCallable, Category = "Health")
    void TakeDamage(float Amount);

protected:
    virtual void BeginPlay() override;

private:
    // Private by default - enforce encapsulation
    UPROPERTY(EditDefaultsOnly, Category = "Health")
    float MaxHealth = 100.0f;

    UPROPERTY(VisibleAnywhere, Category = "Health")
    float CurrentHealth;
};
```

## Best Practices

| Practice | Reason |
|----------|--------|
| Forward declarations over #includes | Reduces compile times and dependencies |
| GENERATED_BODY() macro | Required for reflection system |
| Private by default | Enforce encapsulation |
| Split large functions | Improves compile time optimization |
| Don't use inline for non-trivial functions | Can increase compile times |

## Header Organization

```cpp
#pragma once

// Engine includes
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"

// Generated header (always last)
#include "MyActor.generated.h"

// Forward declarations
class UStaticMeshComponent;

// Delegates
DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnDeathSignature);

// Class declaration
UCLASS()
class MYGAME_API AMyActor : public AActor
{
    GENERATED_BODY()
    // ...
};
```

## Notes

- Don't worry about precompiled header setup (Unreal Build Tool handles it)
- Keep headers minimal - implementation details in .cpp files

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/gameplay-classes-in-unreal-engine
