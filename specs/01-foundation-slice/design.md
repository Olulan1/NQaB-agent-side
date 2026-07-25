# Design

## Design goal
Build a minimal Godot 2D slice that proves the game can support corridor movement, basic combat, and a clean room transition across the first 3 floors.

## Source context
- `dev-thoughts/NQaB base design.md`

## Scene structure

- `Main.tscn`: entry scene and root of the slice.
- `Room01.tscn`: first corridor room, built to launch immediately.
- `Floor01.tscn`: first floor, tuned to prove clean movement.
- `Floor02.tscn`: second floor, adds one small pressure point without blocking movement.
- `Floor03.tscn`: third floor, closes the first playable slice.
- `Player.tscn`: player controller and combat actions.
- `EnemyBasic.tscn`: first enemy type used to test pressure and damage.
- `Elevator.tscn`: exit or transition trigger that ends the room.

## Minimal systems

- Player movement:
  - left/right movement
  - jump
  - crouch
  - blaster fire
- Combat:
  - simple player damage
  - simple enemy damage
  - clear hit feedback
- Transition:
  - three connected floors
  - one exit/elevator interaction
  - one clean advance out of the room

## Implementation order

1. Make `Main.tscn` launch the slice.
2. Build `Floor01.tscn` so movement is fully unhindered.
3. Add `Player.tscn` with the required controls.
4. Build `Floor02.tscn` and add the first light enemy pressure.
5. Build `Floor03.tscn` and verify the 3-floor loop closes cleanly.

## Constraints

- Keep the slice intentionally small.
- Avoid adding extra weapons, inventory, or progression logic.
- Do not expand beyond the first 3 floors yet.
- Do not introduce backtracking or branch paths.
- Keep the implementation strictly 2D.
- Do not introduce 3D systems or non-2D editor features.

## Success criteria

- The project opens directly into the first room.
- The first 3 floors are reachable and playable in sequence.
- The player can move, jump, crouch, and shoot.
- The enemy can be engaged and can hurt the player.
- The room can be completed through the elevator or exit trigger.
- The slice is ready to be used as the base for the next phase.
