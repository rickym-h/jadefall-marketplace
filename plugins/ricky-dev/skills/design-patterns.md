---
name: design-patterns
description: Design patterns (Strategy, Factory, Repository, Observer, Decorator, Command, Adapter, Builder) with UE5 examples. Use when designing new features, choosing between patterns, reviewing code with smells like growing switch/if chains, scattered spawn logic, direct platform SDK calls, deep inheritance hierarchies, or tightly coupled event handling.
---

# Design Patterns for Flexible, Extensible Code

These patterns solve recurring problems in ways that keep code maintainable. Each entry covers: what problem it solves, when to use it, when NOT to use it, and its SOLID alignment.

---

## Pattern Selection Guide

| Situation | Consider |
|---|---|
| Behaviour varies and might grow (AI states, fire modes, damage types) | Strategy |
| Spawning actors of varying types based on data | Factory |
| Game logic shouldn't know about save/online details | Repository |
| Multiple systems react to the same game event | Observer (delegates) |
| Cross-cutting concerns on an object | Decorator / Component stacking |
| Operations need to be queued, predicted, or replayed | Command |
| External SDK needs a seam (Online Subsystem, analytics) | Adapter |
| Complex object setup with many optional parameters | Builder |

**UE5 smell → Pattern mapping:**

| Code smell | Pattern to reach for |
|---|---|
| `if/else` chain on `EEnemyType`, `EDamageType`, etc. that grows | Strategy |
| `SpawnActor<AConcreteClass>` scattered across codebase | Factory |
| `UGameplayStatics::SaveGameToSlot` in gameplay logic | Repository |
| Component calling other subsystems directly on event | Observer (delegate) |
| `Cast<AHUD>()` / `Cast<UAudioManager>()` inside unrelated components | Observer (delegate) |
| Deep Actor inheritance chain (5+ levels) | Decorator or Component composition |
| Input actions handled with growing if/switch | Command |
| `IOnlineSubsystem::Get()->GetX()->DoY()` in game logic | Adapter |

---

## Strategy
**Problem:** Multiple algorithms or behaviours for the same operation; switching between them.

**Structure:** Define a family of algorithms behind a shared interface. The context holds a reference to the interface and delegates to it.

**Use when:** You have an if/switch chain selecting between behaviours that could grow; you want to test behaviours independently; behaviours are interchangeable at runtime.

**Avoid when:** There's only one behaviour and no concrete reason to expect more (YAGNI).

**SOLID:** Directly enables OCP (new strategies don't touch existing code), SRP (each strategy has one job), DIP (context depends on abstraction).

**UE5 example:**
```cpp
// Violation — grows with every new AI state
void AEnemy::UpdateAI(float DeltaTime)
{
    if (State == EAIState::Aggressive)  { ChaseAndAttack(DeltaTime); }
    else if (State == EAIState::Defensive) { RetreatAndHeal(DeltaTime); }
    else if (State == EAIState::Patrol)    { FollowPatrolPath(DeltaTime); }
    // New state = edit this method
}
```

Fix: `IEnemyBehavior` UINTERFACE with `UAggressiveBehavior`, `UDefensiveBehavior`, `UPatrolBehavior` as `UActorComponent` subclasses. `AEnemy` holds a `TObjectPtr<UActorComponent> CurrentBehavior` and calls `IBehavior::Execute_Tick(CurrentBehavior, DeltaTime)`. Adding a new state = new component class, `AEnemy` unchanged.

This maps naturally onto UE5's component model: swap the active component to swap the behaviour at runtime.

Weapon fire modes are another clean Strategy fit: `IFireModeStrategy` with `UAutoFireMode`, `UBurstFireMode`, `USingleShotMode` — the weapon delegates to whichever is currently active.

---

## Factory / Abstract Factory
**Problem:** Object creation logic is complex, varies by context, or needs to be decoupled from usage.

**Structure:** A factory method or class encapsulates construction decisions. Callers request an object without knowing how it's built.

**Use when:** Construction is non-trivial; you want to vary the concrete type without changing callers; testing requires substituting fake implementations.

**Avoid when:** Construction is a single `SpawnActor<T>()` call with no variation — a factory just adds indirection (KISS violation).

**SOLID:** DIP (callers depend on the factory abstraction), OCP (new products added without changing callers), SRP (creation logic extracted from consumer).

**UE5 example:**
```cpp
// Violation — spawn logic scattered across the codebase, each caller picks a concrete type
AEnemy* Enemy = GetWorld()->SpawnActor<AInfantryEnemy>(SpawnLocation, SpawnRotation);
// ...elsewhere...
AEnemy* Boss = GetWorld()->SpawnActor<ABossEnemy>(SpawnLocation, SpawnRotation);
```

Fix: `UEnemyFactory` with a `SpawnEnemy(EEnemyType Type, FTransform Transform)` method. It reads from a data table mapping `EEnemyType` to the correct `TSubclassOf<AEnemy>`. Callers never reference concrete enemy classes — they request a type and get back an `AEnemy*`. Adding a new enemy type = add a row to the data table, no caller changes.

Widget factories follow the same pattern: a `UWidgetFactory::CreateScreenWidget(EWidgetType)` keeps UI creation decisions centralised rather than scattered across the codebase.

---

## Repository
**Problem:** Game/business logic is coupled to data access details (save games, online subsystems, databases).

**Structure:** An interface defines the data operations the domain needs. The implementation handles storage mechanics.

**Use when:** You want to test game logic without real save files or network calls; you might swap storage implementations (local vs cloud); you want a clean seam between gameplay and infrastructure.

**Avoid when:** The game is a thin data wrapper with no real logic — the abstraction adds friction without value.

**SOLID:** DIP (game logic depends on repo interface, not `UGameplayStatics`), SRP (game logic doesn't contain save file mechanics), ISP (the interface exposes only what callers actually need).

**UE5 example:**
```cpp
// Violation — APlayerController is coupled to local save implementation
void APlayerController::SavePlayerProgress()
{
    UMyProgressSave* Save = Cast<UMyProgressSave>(
        UGameplayStatics::LoadGameFromSlot(TEXT("Progress"), 0));
    Save->Level = PlayerLevel;
    Save->XP = PlayerXP;
    UGameplayStatics::SaveGameToSlot(Save, TEXT("Progress"), 0);
}
```

Fix: `IProgressRepository` UINTERFACE with `SaveProgress(FPlayerProgress)` and `LoadProgress() → FPlayerProgress`. `ULocalProgressRepository` wraps `UGameplayStatics`. `UCloudProgressRepository` wraps the online subsystem. `APlayerController` holds `IProgressRepository*` injected via `BeginPlay` from `UGameInstance`. Swapping to cloud saves = new class, no controller changes.

Leaderboards are another natural fit: `ILeaderboardRepository` hides whether you're talking to EOS, Steam, or a mock for testing.

---

## Observer / Event-Driven
**Problem:** A change in one component needs to trigger behaviour in others, but you don't want tight coupling between them.

**Structure:** Publishers emit events via delegates; subscribers bind to them independently.

**Use when:** Multiple independent systems need to react to the same event; you want to add reactions without modifying the publisher; decoupling is more valuable than explicit call chains.

**Avoid when:** There is always exactly one subscriber and it won't grow — a direct method call is simpler and more traceable (KISS). Events make control flow implicit; overuse makes systems hard to debug.

**SOLID:** OCP (new subscribers don't modify the publisher), DIP (publisher depends on delegate abstraction, not concrete handlers), SRP (each subscriber handles one concern).

**UE5 example:**
```cpp
// Violation — UHealthComponent is coupled to every system that cares about health
void UHealthComponent::ApplyDamage(float Amount)
{
    CurrentHealth -= Amount;
    // Direct calls to unrelated systems — coupling in all directions
    Cast<AHUD>(GetOwner())->UpdateHealthBar(CurrentHealth);
    Cast<UAudioManager>(GetOwner())->PlayHurtSound();
    Cast<UVFXManager>(GetOwner())->SpawnBloodEffect();
}
```

Fix: `UHealthComponent` declares a delegate:
```cpp
DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FOnHealthChanged, float, NewHealth, float, Delta);
UPROPERTY(BlueprintAssignable)
FOnHealthChanged OnHealthChanged;
```

`AHUD`, `UAudioManager`, and `UVFXManager` each `AddDynamic` to `OnHealthChanged` during `BeginPlay`. `UHealthComponent` only modifies health and broadcasts — it has zero knowledge of who listens.

This IS UE5's native model. GAS `GameplayEvent` tags, `FOnAttributeChangeData` callbacks, and `AbilitySystemComponent` delegates are all Observer-pattern implementations built into the engine.

---

## Decorator
**Problem:** You need to add behaviour (logging, caching, validation, retry) to an object without modifying it or creating a deep subclass hierarchy.

**Structure:** Wrap an object behind the same interface. The decorator adds behaviour and delegates to the wrapped instance.

**Use when:** You need to compose cross-cutting concerns onto an object; inheritance would create a combinatorial explosion of subclasses.

**Avoid when:** The added behaviour is core to the type, not a cross-cutting concern — it belongs inside the class.

**SOLID:** OCP (behaviour added without modifying the base), SRP (each decorator has one cross-cutting concern), DIP (decorators depend on the abstraction).

**UE5 example:**
UE5 doesn't use Decorator the same way as C#/.NET, but the concept maps onto a few patterns:

**GAS Magnitude Calculators** are decorators: `UGameplayEffectExecutionCalculation` wraps attribute changes with additional logic (scaling, clamping, conditional bonuses) without modifying the core attribute system.

**Component wrapping:** An `ULoggingWeaponComponent` wrapping `UBaseWeaponComponent` behind `IWeapon` — it logs every shot and delegates to the real implementation:
```cpp
void ULoggingWeaponComponent::Fire(const FVector& Direction)
{
    UE_LOG(LogCombat, Log, TEXT("Shot fired by %s"), *GetOwner()->GetName());
    InnerWeapon->Fire(Direction); // delegate to real weapon
}
```

In practice, prefer stacking `UActorComponent` subclasses over classical Decorator when possible — it's more idiomatic UE5 and plays better with the reflection system.

---

## Command
**Problem:** You need to encapsulate an operation as an object — for queuing, undo/redo, input replay, or uniform dispatching.

**Structure:** Each operation becomes a class implementing a common `Execute()` interface. A dispatcher executes commands.

**Use when:** Operations need to be queued, replayed, or undone; you want a uniform dispatch mechanism; you want to decouple the caller from the handler.

**Avoid when:** The operation is simple and called directly in one place — the indirection adds complexity without benefit (KISS/YAGNI).

**SOLID:** SRP (each command encapsulates one operation), OCP (new commands don't change the dispatcher), DIP (caller depends on the command abstraction).

**UE5 example:**
`FGameplayAbilitySpec` in GAS is essentially a Command object — it encapsulates "activate this ability" as data that can be queued, predicted, replicated, and rolled back.

For multiplayer input prediction, a Command queue is invaluable:
```cpp
// IPlayerCommand interface
class IPlayerCommand
{
public:
    virtual void Execute(APlayerCharacter* Character) = 0;
    virtual void Undo(APlayerCharacter* Character) {} // optional for rollback
};

// Commands are objects that can be serialised, replicated, replayed
class FMoveCommand : public IPlayerCommand { ... };
class FAttackCommand : public IPlayerCommand { ... };
```

A `UCommandQueue` processes them in order. Client predicts by executing locally; server validates; rollback replays commands from a checkpoint. This is the pattern behind client-side prediction in games like Overwatch.

---

## Adapter
**Problem:** You need to use an external system or platform API behind a clean interface your game logic controls.

**Structure:** A wrapper class translates between your interface and the external interface.

**Use when:** You don't control the external interface; you want to swap implementations; you want to test without hitting the real external system.

**SOLID:** DIP (game logic depends on your interface, not the SDK), OCP (swapping platforms = new adapter, no game logic changes).

**UE5 example:**
The Online Subsystem is the canonical Adapter target. Rather than calling into `IOnlineSubsystem` directly from gameplay code:

```cpp
// Violation — game logic coupled to a specific online platform
IOnlineLeaderboardsPtr Leaderboards = IOnlineSubsystem::Get()->GetLeaderboardsInterface();
Leaderboards->ReadLeaderboards(Players, ReadObject);
```

Fix: `ILeaderboardService` with `SubmitScore(int32 Score)` and `FetchTopScores(int32 Count, FOnScoresFetched Callback)`. `UEOSLeaderboardService` and `USteamLeaderboardService` implement it. Game logic only knows about `ILeaderboardService*`.

This is especially valuable in UE5 because the Online Subsystem API is verbose, platform-specific, and changes between EOS SDK versions. Your game code should be insulated from all of that.

Same pattern for analytics (`IAnalyticsService`), push notifications, cloud saves, and voice chat — any integration you don't control.

---

## Builder
**Problem:** Object construction requires many parameters, optional components, or a multi-step assembly process.

**Structure:** A builder class accumulates configuration through a fluent API, then produces the object.

**Use when:** Constructors with >4-5 parameters; objects with many optional parts; test setup that would otherwise require many overloaded constructors.

**Avoid when:** Construction is simple — a factory method is sufficient.

**UE5 example:**
`FGameplayEffectSpec` construction is notoriously verbose. A builder simplifies test setup and complex effect composition:
```cpp
FGameplayEffectSpec Spec = FGameplayEffectSpecBuilder(FireDamageEffectClass)
    .WithLevel(AbilityLevel)
    .WithContext(EffectContext)
    .WithSetByCallerMagnitude(DamageTag, CalculatedDamage)
    .Build();
```

Enemy spawn configuration with many optional parameters (patrol path, aggro radius, loot table, difficulty scale, squad assignment) is another Builder candidate — rather than one massive `FEnemySpawnParams` struct with most fields unused per call.
