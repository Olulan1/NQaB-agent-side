# Design

## Design goal
Build a minimal Godot 2D slice that proves the game can support corridor movement, basic combat, and a clean room transition.

## Scene structure

- `Main.tscn`: entry scene and root of the slice.
- `Room01.tscn`: first corridor room, built to launch immediately.
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
  - one corridor room
  - one exit/elevator interaction
  - one clean advance out of the room

## Implementation order

1. Make `Main.tscn` launch the slice.
2. Build `Room01.tscn` as a single test corridor.
3. Add `Player.tscn` with the required controls.
4. Add `EnemyBasic.tscn` and wire damage exchange.
5. Add `Elevator.tscn` and verify the room can be exited cleanly.

## Constraints

- Keep the slice intentionally small.
- Avoid adding extra weapons, inventory, or progression logic.
- Do not expand into multiple floors yet.
- Do not introduce backtracking or branch paths.

## Success criteria

- The project opens directly into the first room.
- The player can move, jump, crouch, and shoot.
- The enemy can be engaged and can hurt the player.
- The room can be completed through the elevator or exit trigger.
- The slice is ready to be used as the base for the next phase.
