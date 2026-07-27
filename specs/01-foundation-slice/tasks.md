# Tasks: 01-foundation-slice

## Overview
Total tasks: 5

## Phase 1: Make It Work (POC)

- [x] 1.1 [P] Make Intro01 fully walkable
  - **Do**:
    1. Keep `Main.tscn` as the entry scene.
    2. Build `Intro01.tscn` as a clean, unobstructed first floor.
    3. Make sure the player can move freely without level geometry blocking basic movement.
  - **Files**: `project.godot`, `Main.tscn`, `Intro01.tscn`, `Player.tscn`
  - **Done when**: Launching the project drops the player into Floor 1 and movement is not hindered by the room layout.
  - **Verify**: Open the project and confirm the first floor loads with clear left/right traversal space.
  - **Commit**: `feat(slice): make floor 1 walkable`

- [x] 1.2 [P] Add the player baseline
  - **Do**:
    1. Create `Player.tscn` with left/right movement, jump, crouch, and blaster fire.
    2. Add only the input actions required for those controls.
    3. Keep the controller simple so movement tuning stays easy.
  - **Files**: `Player.tscn`, `project.godot`
  - **Done when**: The player can move, jump, crouch, and shoot on Floor 1 without collisions or input friction.
  - **Verify**: Play Floor 1 and confirm each input works as expected.
  - **Commit**: `feat(slice): add player baseline`

- [x] 1.3 [P] Add Intro02 as the first pressure check
  - **Do**:
    1. Build `Intro02.tscn` with one simple threat or obstacle.
    2. Keep the path readable so movement remains the primary feel test.
    3. Avoid introducing anything that obscures whether the player controller still feels clean.
  - **Files**: `Intro02.tscn`, `EnemyBasic.tscn`, `Player.tscn`
  - **Done when**: Floor 2 adds a small amount of pressure without making movement feel awkward.
  - **Verify**: Play Floors 1-2 and confirm traversal remains smooth.
  - **Commit**: `feat(slice): add floor 2 pressure`

- [ ] 1.4 [P] Add Floor 3 and close the first slice
  - **Do**:
    1. Build `Floor03.tscn` as the third and final floor in the initial slice.
    2. Add the minimal exit or transition needed to complete the 3-floor loop.
    3. Keep the floor concise so it remains tuneable later.
  - **Files**: `Floor03.tscn`, `Elevator.tscn`, `Main.tscn`
  - **Done when**: Floors 1-3 can be played in sequence and the loop closes cleanly.
  - **Verify**: Play from Floor 1 through Floor 3 and confirm the final transition works.
  - **Commit**: `feat(slice): complete 3-floor loop`

- [ ] 1.5 [VERIFY] Tune the 3-floor slice for readability
  - **Do**:
    1. Play the full 3-floor sequence.
    2. Adjust room spacing, collision, and pacing only where movement feels hindered.
    3. Keep the slice minimal and avoid adding new systems.
  - **Files**: `Intro01.tscn`, `Intro02.tscn`, `Floor03.tscn`, `Player.tscn`
  - **Done when**: The 3-floor slice feels clear, playable, and tuneable without extra complexity.
  - **Verify**: Run the full sequence and confirm movement stays consistent across all three floors.
  - **Commit**: `feat(slice): tune first 3 floors`
