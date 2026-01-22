---
description: Writing UE5 C++ code, naming variables, functions, or classes
---

# UE5 C++ Coding Standards

Follow Epic's coding standards for Unreal Engine C++ development.

## Class Prefixes

| Prefix | Type |
|--------|------|
| U | UObject-derived classes |
| A | AActor-derived classes |
| S | Slate widget classes |
| F | Structs and non-UObject classes |
| T | Template classes |
| E | Enum types |
| I | Interface classes |

## Naming Conventions

- **PascalCase** for all names (no underscores between words)
- **Boolean prefix**: `b` (e.g., `bIsActive`, `bDead`, `bCanJump`)
- **U.S. English spelling** in code and comments
- **No Hungarian notation** except for type prefixes above

## Examples

```cpp
// Classes
class UHealthComponent : public UActorComponent
class ABaseCharacter : public ACharacter
class FGameStats  // Non-UObject struct

// Enums
UENUM(BlueprintType)
enum class EWeaponState : uint8
{
    Idle,
    Firing,
    Reloading
};

// Variables
UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
float MaxHealth = 100.0f;

UPROPERTY(VisibleAnywhere, BlueprintReadOnly)
bool bIsAlive = true;

// Functions
UFUNCTION(BlueprintCallable, Category = "Combat")
void TakeDamage(float DamageAmount);

UFUNCTION(BlueprintPure)
bool IsAlive() const;
```

## Property Specifiers

| Specifier | Use Case |
|-----------|----------|
| EditAnywhere | Editable in editor and instances |
| EditDefaultsOnly | Editable only in Blueprint defaults |
| VisibleAnywhere | Read-only in editor |
| BlueprintReadWrite | Read/write from Blueprint |
| BlueprintReadOnly | Read-only from Blueprint |
| BlueprintCallable | Function callable from Blueprint |
| BlueprintPure | Pure function (no side effects) |

## Best Practices

- Use **inline initialization** for member variables in class declaration
- Use **forward declarations** to reduce compile times
- Add **UPROPERTY/UFUNCTION macros** for reflection and GC tracking

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/epic-cplusplus-coding-standard-for-unreal-engine
