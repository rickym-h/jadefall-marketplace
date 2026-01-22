---
description: Working with UE5 pointers, memory allocation, or object lifecycle
---

# UE5 C++ Memory Management

Proper memory management in Unreal Engine requires understanding the garbage collection system.

## UObject Pointers

**Always use UPROPERTY() for UObject pointers** - this enables garbage collection tracking.

```cpp
// CORRECT - GC will track this reference
UPROPERTY()
UStaticMeshComponent* MeshComponent;

UPROPERTY()
TObjectPtr<UStaticMeshComponent> MeshComponent;  // UE5 preferred

// WRONG - GC cannot track, may cause crashes
UStaticMeshComponent* MeshComponent;  // Raw pointer without UPROPERTY
TSharedPtr<UStaticMeshComponent> MeshComponent;  // Never use smart pointers for UObjects!
```

## Smart Pointers (Non-UObjects Only)

| Type | Use Case |
|------|----------|
| TSharedPtr<T> | Shared ownership of non-UObject |
| TWeakPtr<T> | Non-owning reference, break circular refs |
| TUniquePtr<T> | Exclusive ownership of non-UObject |
| TObjectPtr<T> | UPROPERTY UObject references (UE5) |

```cpp
// For non-UObject types only
TSharedPtr<FMyCustomStruct> SharedData;
TWeakPtr<FMyCustomStruct> WeakRef;
TUniquePtr<FMyCustomStruct> UniqueData;
```

## Object Creation

```cpp
// Runtime object creation (outside constructors)
UMyComponent* Comp = NewObject<UMyComponent>(this);

// Constructor only - creates default subobjects
USceneComponent* Root = CreateDefaultSubobject<USceneComponent>(TEXT("Root"));
```

## Rules

| Rule | Reason |
|------|--------|
| UPROPERTY() for all UObject pointers | GC tracking |
| TSharedPtr/TWeakPtr for non-UObjects only | GC doesn't understand smart pointers |
| NewObject<T>() at runtime | Proper GC registration |
| CreateDefaultSubobject<T>() in constructors only | CDO creation semantics |
| TWeakPtr to break circular references | Prevent memory leaks |
| Never AsShared/SharedThis in constructors | Object not fully constructed |
| Pass as const& not smart pointer | Performance optimization |

## Common Mistakes

```cpp
// WRONG - Smart pointer for UObject
TSharedPtr<AActor> MyActor;

// WRONG - CreateDefaultSubobject outside constructor
void BeginPlay()
{
    Mesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("Mesh"));
}

// WRONG - Raw pointer without UPROPERTY
AActor* CachedTarget;  // May become invalid after GC
```

## Correct Patterns

```cpp
UPROPERTY()
TObjectPtr<AActor> CachedTarget;  // UE5 style

// Check validity before use
if (IsValid(CachedTarget))
{
    // Safe to use
}
```

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/unreal-object-handling-in-unreal-engine
