---
description: Working with UE5 GameMode, PlayerController, Pawn, Character, GameState, or PlayerState
---

# UE5 C++ Gameplay Framework

Understanding the core gameplay framework classes and their responsibilities.

## Class Responsibilities

| Class | Authority | Responsibility |
|-------|-----------|----------------|
| GameMode | Server only | Game rules, spawning, class specifications |
| GameState | Replicated | Match state, communicate server→clients |
| PlayerController | Per player | Input processing, camera, UI, persists between deaths |
| PlayerState | Replicated | Player data (score, name), persists between deaths |
| Pawn | Transient | Physical representation, possessed/unpossessed |
| Character | Transient | Pawn + CharacterMovementComponent + Capsule |

## GameMode (Server Only)

```cpp
UCLASS()
class AMyGameMode : public AGameModeBase
{
    GENERATED_BODY()

public:
    AMyGameMode();

    virtual void PostLogin(APlayerController* NewPlayer) override;
    virtual AActor* ChoosePlayerStart_Implementation(AController* Player) override;

    // Game rules
    void StartMatch();
    void EndMatch();
};
```

**Never access GameMode from clients** - it only exists on the server.

## GameState (Replicated)

```cpp
UCLASS()
class AMyGameState : public AGameStateBase
{
    GENERATED_BODY()

public:
    // Replicated match data
    UPROPERTY(Replicated)
    int32 MatchTimeRemaining;

    UPROPERTY(ReplicatedUsing = OnRep_MatchState)
    EMatchState CurrentMatchState;

    UFUNCTION()
    void OnRep_MatchState();
};
```

## PlayerController

```cpp
UCLASS()
class AMyPlayerController : public APlayerController
{
    GENERATED_BODY()

public:
    virtual void SetupInputComponent() override;

    // Input handling
    void MoveForward(float Value);

    // Don't store player data here - use PlayerState instead
};
```

## PlayerState (Replicated)

```cpp
UCLASS()
class AMyPlayerState : public APlayerState
{
    GENERATED_BODY()

public:
    // Persistent, replicated player data
    UPROPERTY(Replicated)
    int32 Score;

    UPROPERTY(Replicated)
    int32 Kills;

    UPROPERTY(Replicated)
    int32 Deaths;
};
```

## Character

```cpp
UCLASS()
class AMyCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    AMyCharacter();

    // CharacterMovementComponent available via GetCharacterMovement()
    // CapsuleComponent is root by default
};
```

## Common Mistakes

| Mistake | Correct Approach |
|---------|------------------|
| Accessing GameMode on client | Use GameState for replicated data |
| Storing player data in PlayerController | Use PlayerState |
| Spawning from PlayerController | GameMode handles spawning |
| Putting persistent data in Pawn/Character | Use PlayerState or PlayerController |

## Access Patterns

```cpp
// Get GameMode (server only)
AMyGameMode* GM = GetWorld()->GetAuthGameMode<AMyGameMode>();

// Get GameState (anywhere)
AMyGameState* GS = GetWorld()->GetGameState<AMyGameState>();

// Get PlayerState from controller
AMyPlayerState* PS = GetPlayerState<AMyPlayerState>();

// Get PlayerController from Pawn
AMyPlayerController* PC = Cast<AMyPlayerController>(GetController());
```

**Documentation:** https://dev.epicgames.com/documentation/en-us/unreal-engine/gameplay-framework-in-unreal-engine
