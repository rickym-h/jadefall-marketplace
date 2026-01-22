---
description: Creating UE5 delegates, event dispatchers, or callback systems
---

# UE5 C++ Delegates & Events

Delegates provide type-safe callbacks for event-driven programming in Unreal Engine.

## Delegate Types

| Type | Blueprint | Multiple Bindings | Use Case |
|------|-----------|-------------------|----------|
| Single | No | No | Internal C++ callbacks |
| Multicast | No | Yes | C++ event broadcasting |
| Dynamic Single | Yes | No | Single Blueprint callback |
| Dynamic Multicast | Yes | Yes | Blueprint event dispatchers |

## Declaration Macros

```cpp
// Single-cast (C++ only)
DECLARE_DELEGATE(FOnSimpleEvent);
DECLARE_DELEGATE_OneParam(FOnHealthChanged, float);
DECLARE_DELEGATE_TwoParams(FOnDamage, float, AActor*);
DECLARE_DELEGATE_RetVal(bool, FOnValidate);

// Multicast (C++ only)
DECLARE_MULTICAST_DELEGATE(FOnSimpleMulticast);
DECLARE_MULTICAST_DELEGATE_OneParam(FOnScoreChanged, int32);

// Dynamic (Blueprint compatible)
DECLARE_DYNAMIC_DELEGATE(FOnDynamicSimple);
DECLARE_DYNAMIC_MULTICAST_DELEGATE(FOnDeathSignature);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnHealthChangedSignature, float, NewHealth);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnDamageSignature, float, Damage, AActor*, Instigator);
```

## Naming Convention

- **F prefix** for delegate type: `FOnScoreChangedSignature`
- **Signature suffix** for type declaration
- **On prefix** for event names

## Blueprint-Exposed Events

```cpp
// In header - declare delegate type
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnHealthChangedSignature, float, NewHealth);

UCLASS()
class UHealthComponent : public UActorComponent
{
    GENERATED_BODY()

public:
    // BlueprintAssignable exposes to Blueprint Event Graph
    UPROPERTY(BlueprintAssignable, Category = "Events")
    FOnHealthChangedSignature OnHealthChanged;

    void TakeDamage(float Amount)
    {
        CurrentHealth -= Amount;
        OnHealthChanged.Broadcast(CurrentHealth);  // Notify all listeners
    }
};
```

## Binding Patterns

```cpp
// C++ binding
MyDelegate.BindUObject(this, &UMyClass::HandleEvent);
MyMulticast.AddUObject(this, &UMyClass::HandleEvent);

// Lambda binding
MyDelegate.BindLambda([](float Value) { /* ... */ });

// Dynamic binding (Blueprint compatible)
MyDynamicDelegate.AddDynamic(this, &UMyClass::HandleEvent);
MyDynamicDelegate.AddUniqueDynamic(this, &UMyClass::HandleEvent);  // Prevents duplicates
```

## Best Practices

| Practice | Reason |
|----------|--------|
| Use AddUniqueDynamic | Prevents duplicate subscriptions |
| Wrap complex data in USTRUCT | Blueprint compatibility |
| Use Multicast for events | Single-cast Events are deprecated |
| Sparse delegates for rare events | Memory optimization |
| Check IsBound() before ExecuteIfBound() | Avoid crashes |

## Unbinding

```cpp
// Always unbind in destructor or when no longer needed
MyDelegate.Unbind();
MyMulticast.RemoveAll(this);
MyDynamicDelegate.RemoveDynamic(this, &UMyClass::HandleEvent);
```

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/delegates-and-lamba-functions-in-unreal-engine
