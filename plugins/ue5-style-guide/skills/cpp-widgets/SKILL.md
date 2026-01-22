---
description: Creating UE5 UMG widgets, UI development, or using BindWidget
---

# UE5 C++ Widgets (UMG)

Best practices for creating UMG widgets with C++ logic and Blueprint visuals.

## Architecture Pattern

**Logic in C++, visuals in Widget Blueprints**

```cpp
// C++ base class handles logic
UCLASS(Abstract)  // Prevent direct instantiation
class MYGAME_API UHealthBarWidget : public UUserWidget
{
    GENERATED_BODY()

protected:
    // Required binding - compilation fails if missing in BP
    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UProgressBar> HealthBar;

    // Optional binding - no error if missing
    UPROPERTY(meta = (BindWidgetOptional))
    TObjectPtr<UTextBlock> HealthLabel;

    // Add BlueprintReadOnly for Graph access
    UPROPERTY(BlueprintReadOnly, meta = (BindWidget))
    TObjectPtr<UImage> DamageFlashImage;

public:
    void SetHealthPercent(float Percent);
};
```

## Naming Conventions

| Type | C++ Name | Blueprint Name |
|------|----------|----------------|
| Widget C++ class | `UHealthBarWidget` | - |
| Widget Blueprint | - | `WBP_HealthBar` |
| Custom base class | `UBUIUserWidget` | - |

## Widget Property Suffixes

| Suffix | Widget Type |
|--------|-------------|
| Label | UTextBlock |
| Panel | Container widgets (UCanvasPanel, UVerticalBox) |
| Image | UImage |
| Button | UButton |
| Bar | UProgressBar |

## BindWidget Rules

```cpp
// Names MUST match exactly between C++ and Blueprint
UPROPERTY(meta = (BindWidget))
TObjectPtr<UProgressBar> HealthBar;  // BP widget must be named "HealthBar"

UPROPERTY(meta = (BindWidgetOptional))
TObjectPtr<UTextBlock> ScoreLabel;  // Optional, won't fail if missing
```

## Base Class Hierarchy

Create intermediate base classes for project-wide functionality:

```cpp
// Project base widget - between UUserWidget and implementations
UCLASS(Abstract)
class MYGAME_API UBUIUserWidget : public UUserWidget
{
    GENERATED_BODY()

protected:
    // Shared functionality for all project widgets
    virtual void NativeConstruct() override;
};

// Subclass custom widgets from project base
UCLASS(Abstract)
class MYGAME_API UBUIButton : public UButton
{
    GENERATED_BODY()
    // Custom button behavior
};
```

## Performance

| Avoid | Use Instead |
|-------|-------------|
| Bind functions (execute every frame) | NativeTick or event-driven updates |
| Tick for all widgets | Events and delegates |
| Frequent widget creation | Widget pooling |

```cpp
// AVOID - Bind runs every frame
// Widget Bind -> GetHealthPercent()

// PREFER - Event-driven
void UHealthComponent::TakeDamage(float Amount)
{
    Health -= Amount;
    OnHealthChanged.Broadcast(Health / MaxHealth);  // Update only when changed
}
```

## Common Setup

```cpp
// HealthBarWidget.h
UCLASS(Abstract)
class UHealthBarWidget : public UBUIUserWidget
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintCallable)
    void SetHealth(float Current, float Max);

protected:
    virtual void NativeConstruct() override;

    UPROPERTY(meta = (BindWidget))
    TObjectPtr<UProgressBar> HealthBar;

    UPROPERTY(meta = (BindWidgetOptional))
    TObjectPtr<UTextBlock> HealthLabel;
};
```

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/umg-ui-designer-for-unreal-engine
