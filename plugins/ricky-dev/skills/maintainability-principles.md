---
name: maintainability-principles
description: SOLID, DRY, YAGNI, and KISS principles with UE5 examples. Use when reviewing code for quality issues, evaluating architecture decisions, refactoring, identifying code smells (god classes, deep inheritance, copy-paste logic, speculative abstractions), or when user asks about SRP, OCP, LSP, ISP, DIP, DRY, YAGNI, or KISS.
---

# Maintainability Principles

A curated reference for evaluating and designing code. Internalize these as lenses, not checklists.

---

## How These Principles Interact

| Tension | Resolution |
|---|---|
| YAGNI vs OCP | Add extension points only when you have 2+ concrete cases, or testability demands it |
| DRY vs SRP | If two pieces of code look the same but change for different reasons, keep them separate |
| KISS vs DIP | An interface for dependency inversion is simple in the right way — it enables testability and decoupling |
| OCP vs KISS | Don't build extension machinery speculatively; add it when the second variant actually arrives |

**When in doubt, start simple (KISS/YAGNI) and refactor toward SOLID as the system grows.** Pre-emptive architecture is speculation. Emergent architecture is evidence-based.

---

## SOLID

### Single Responsibility Principle (SRP)
A class/module should have **one reason to change** — one stakeholder whose needs drive its evolution.

**Violations:**
- A class that does business logic AND persistence (changes for domain reasons AND database schema reasons)
- A method named `ValidateAndSave`, `ParseAndTransform` — "and" signals two responsibilities
- God classes / manager classes accumulating unrelated behavior
- Methods >20 lines often contain hidden multiple responsibilities

**Fix pattern:** Ask "what stakeholder would ask me to change this?" If the answer is more than one kind of stakeholder, split.

**UE5 example:**
`APlayerCharacter` that handles input, movement, combat, health, inventory, and HUD updates all in one class. It changes whenever the designer tweaks combat, the programmer adds an item type, or the UI artist changes the health bar — three completely different stakeholders.

Fix: extract to components. `UCombatComponent` owns combat logic and changes only for combat reasons. `UInventoryComponent` owns item logic. `APlayerCharacter` becomes a thin orchestrator that wires components together — it only changes when the top-level character contract changes.

The "and" signal in UE5: `HandleDamageAndUpdateUI()`, `ApplyEffectAndNotifyServer()`. Each "and" is a split waiting to happen.

---

### Open/Closed Principle (OCP)
Code should be **open for extension, closed for modification**. New behavior should be achievable by adding code, not changing existing code.

**Violations:**
- Switch/if-else chains on type that grow with each new variant
- Methods that require editing every time a new case is added
- Hard-coded behavior that should be configurable or overridable

**Fix pattern:** Introduce an abstraction (interface, strategy, plugin) that new variants implement. Existing code doesn't change; new code slots in.

**UE5 example:**
```cpp
// Violation — every new damage type requires editing this method
void AEnemy::TakeDamage(float Amount, EDamageType Type)
{
    if (Type == EDamageType::Fire)       { ApplyBurnEffect(); }
    else if (Type == EDamageType::Poison) { ApplyPoisonEffect(); }
    else if (Type == EDamageType::Ice)    { ApplySlow(); }
    // New type = edit this method
}
```

Fix: a `UDamageEffect` base class (or `UINTERFACE`) with subclasses `UFireDamageEffect`, `UPoisonDamageEffect`. `AEnemy::TakeDamage` receives a `UDamageEffect*` and calls `Effect->Apply(this)`. Adding a new damage type = new class, no modification to `AEnemy`.

In GAS this is natural: `UGameplayEffect` subclasses extend behaviour without touching the ability system core.

---

### Liskov Substitution Principle (LSP)
Subtypes must be **fully substitutable** for their base types without breaking correctness.

**Violations:**
- Derived class throws `NotImplementedException` for inherited methods
- Override changes the semantic meaning of the base behaviour
- `if (obj is SpecificType)` to handle a subtype differently — classic LSP smell
- Subclass that weakens postconditions or strengthens preconditions

**Fix pattern:** If a subtype can't honour the base contract, it shouldn't extend that base. Prefer composition or a separate interface hierarchy.

**UE5 example:**
Not calling `Super::BeginPlay()` in an override is an LSP violation — the engine's lifecycle contract requires the super chain. Any system relying on the base `BeginPlay` completing (component registration, replication setup) breaks silently.

Type-checking smell in UE5:
```cpp
// Violation — caller has to know about subtypes
void AWeaponPickup::OnOverlap(AActor* OtherActor)
{
    if (APlayerCharacter* Player = Cast<APlayerCharacter>(OtherActor))
    {
        Player->AddWeaponToInventory(this); // only works for one subtype
    }
}
```
Fix: introduce an `IInventoryHolder` UINTERFACE. `OnOverlap` calls `IInventoryHolder::Execute_AddItem(OtherActor, this)`. Any actor implementing the interface works — no casting required.

---

### Interface Segregation Principle (ISP)
Clients should **not be forced to depend on methods they don't use**. Prefer many small, focused interfaces over few large ones.

**Violations:**
- Interface with >5-7 methods often signals bloat
- Implementers leaving methods as no-ops or throwing `NotImplementedException`
- "Header interfaces" that mirror a single concrete class exactly (no real abstraction)
- A client that only uses 2 of 8 interface methods

**Fix pattern:** Split the fat interface into role interfaces. A class can implement multiple role interfaces.

**UE5 example:**
A fat `ICombatEntity` UINTERFACE with `GetHealth`, `TakeDamage`, `Attack`, `Dodge`, `UseAbility`, `GetWeapon`, `GetArmor`. A destructible barrel implements `ICombatEntity` but must stub `Attack`, `Dodge`, `UseAbility`, and `GetWeapon` as empty no-ops — it only cares about taking damage.

Fix: split into `IDamageable { TakeDamage, GetHealth }`, `IAttacker { Attack }`, `IAbilityUser { UseAbility }`. The barrel implements only `IDamageable`. The player character implements all three. Systems that only need to deal damage accept `IDamageable*` and never know about `IAttacker`.

---

### Dependency Inversion Principle (DIP)
High-level modules should **depend on abstractions**, not low-level concretions. Both should depend on abstractions.

**Violations:**
- `new ConcreteService()` inside business logic (hidden coupling)
- Static method calls creating hidden, untestable dependencies
- Service locator anti-pattern: resolving dependencies at runtime instead of declaring them

**Fix pattern:** Declare dependencies as constructor-injected interfaces. High-level policy owns the abstraction; low-level detail implements it.

**UE5 example:**
```cpp
// Violation — APlayerCharacter is tightly coupled to a specific save implementation
void APlayerCharacter::SaveProgress()
{
    UMySaveGame* Save = Cast<UMySaveGame>(UGameplayStatics::LoadGameFromSlot(...));
    Save->PlayerLevel = Level;
    UGameplayStatics::SaveGameToSlot(Save, ...);
}
```

Fix: introduce `IProgressRepository` (a UINTERFACE or pure abstract C++ class). `APlayerCharacter` holds a reference to `IProgressRepository*` set during `BeginPlay` via the owning `UGameInstance`. The concrete `ULocalSaveRepository` is an implementation detail the character never knows about. Swapping to cloud saves = new class, no character changes.

Another common DIP smell in UE5: reaching into the subsystem directly in game logic:
```cpp
// Violation
UMyInventorySubsystem* Inv = GetGameInstance()->GetSubsystem<UMyInventorySubsystem>();
```
If game logic needs inventory, it should declare an `IInventoryService*` dependency — not reach through the game instance to a concrete subsystem.

---

## DRY — Don't Repeat Yourself

Every piece of **knowledge** should have a single authoritative representation. DRY is about knowledge duplication, not just code that looks similar.

**Violations:**
- Copy-pasted logic blocks
- Same business rule expressed differently in multiple places
- Same constant defined in multiple places

**Important nuance:**
- Two methods that look similar but change for **different reasons** are NOT duplication — they just happen to look alike today
- Removing duplication across module boundaries can create coupling worse than the duplication
- "Rule of three" — duplicate twice before abstracting; ensure the pattern is real before creating an abstraction

**UE5 example:**
`FHitResult` parsing logic (extracting surface type, hit bone, impact normal) copy-pasted into `AWeapon`, `AGrenade`, `UMeleeComponent`, and `AEnvironmentHazard`. When the parsing logic needs to change (new surface types), it breaks in four places.

Fix: a standalone `FHitResultUtils::ExtractSurfaceInfo(const FHitResult&)` function. One authoritative representation.

Another common UE5 DRY violation: team colour determination logic scattered across `AHUD`, `APlayerState`, and `ANameplateWidget` — each computing it slightly differently. It belongs once in `AGameState` and is queried by everything else.

---

## YAGNI — You Aren't Gonna Need It

Build what is **required now**. Speculative code has a maintenance cost from day one.

**Violations:**
- Configurability nobody asked for
- Abstract base class with only one implementation and no concrete plan for more
- Generic/parameterized solution when a specific one would suffice
- Unused parameters, flags, or configuration options

**Important nuance:**
- An interface introduced for **Dependency Inversion** is NOT a YAGNI violation — it serves a concrete architectural purpose
- The question is: does this complexity serve a current, concrete need?

**UE5 example:**
Building a full generic interpolation subsystem with configurable easing curves, event callbacks, and multi-target support when the only current requirement is fading one HUD element in and out. A `FMath::Lerp` in a tick function is the KISS+YAGNI answer.

Marking every method `virtual` in an Actor subclass "in case we need to override later" — each unnecessary virtual adds vtable overhead and signals false extensibility intent to future readers.

Designing an elaborate versioned save system with migration support before shipping a single feature that actually saves data. Build the save system when you have things to save, and add versioning when you have two incompatible versions.

---

## KISS — Keep It Simple

The **simplest solution that correctly solves the problem** is usually the best. Complexity should be earned by concrete requirements.

**Violations:**
- Deep inheritance hierarchies where composition would be cleaner
- Design pattern applied for its own sake
- Deeply nested conditionals that could be flattened with early returns
- Unnecessary indirection layers that just delegate

**The test:** Can a new developer understand this code in 5 minutes? If not, is the complexity justified by a real requirement?

**UE5 example:**
Deep Actor inheritance is the UE5 KISS violation par excellence:
`AActor` → `ABaseCharacter` → `AHumanoidCharacter` → `APlayableCharacter` → `AMainPlayerCharacter` — five levels of inheritance to add a camera and input. Each level adds coupling; a change to `AHumanoidCharacter` ripples through four subclasses.

UE5's component model exists precisely to solve this. `ACharacter` + `UCombatComponent` + `UInventoryComponent` + `UCameraControlComponent` is flatter, independently testable, and recomposable.

Re-implementing movement prediction from scratch when `UCharacterMovementComponent` already provides it is another KISS violation — fighting the engine rather than extending it.
