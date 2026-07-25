# Tasks: 01-foundation-slice

## Overview
Total tasks: 4

## Phase 1: Make It Work (POC)

- [ ] 1.1 [P] Create the first playable room
  - **Do**:
    1. Add `Main.tscn` as the project entry scene.
    2. Add a single corridor room that loads at launch.
    3. Make the room the first visible play space with no manual setup.
  - **Files**: `project.godot`, `Main.tscn`, `Room01.tscn`
  - **Done when**: Pressing Play opens directly into the first corridor room.
  - **Verify**: Open the project in Godot and confirm the first room loads on launch.
  - **Commit**: `feat(slice): create first playable room`

- [ ] 1.2 [P] Add the player baseline
  - **Do**:
    1. Create `Player.tscn` with left/right movement, jump, crouch, and blaster fire.
    2. Add the minimum input actions needed for those controls.
    3. Keep the implementation simple and readable.
  - **Files**: `Player.tscn`, `project.godot`
  - **Done when**: The player can move, jump, crouch, and shoot inside the first room.
  - **Verify**: Play the project and confirm all four inputs respond.
  - **Commit**: `feat(slice): add player movement and blaster`

- [ ] 1.3 [P] Add the first enemy and damage loop
  - **Do**:
    1. Create `EnemyBasic.tscn` as the first enemy.
    2. Add player damage and enemy hit resolution.
    3. Tune the enemy so the player must react, not just walk forward.
  - **Files**: `EnemyBasic.tscn`, `Player.tscn`, `Room01.tscn`
  - **Done when**: The player can fight one enemy and take damage from it.
  - **Verify**: Play the room and confirm the enemy can be damaged and can damage the player.
  - **Commit**: `feat(slice): add first enemy interaction`

- [ ] 1.4 [VERIFY] Add the elevator exit and close the loop
  - **Do**:
    1. Create `Elevator.tscn` or an equivalent exit trigger.
    2. Make it advance the player to the next room or placeholder transition.
    3. Confirm the first slice can be played start to finish without breaking flow.
  - **Files**: `Elevator.tscn`, `Room01.tscn`, `Main.tscn`
  - **Done when**: The room can be completed and the transition works cleanly.
  - **Verify**: Play from spawn to exit and confirm the transition triggers.
  - **Commit**: `feat(slice): complete first playable loop`
