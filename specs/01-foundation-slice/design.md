# Design

## Scene structure
- `Main.tscn`: entry point
- `Player.tscn`: movement, crouch, jump, blaster
- `Room01.tscn`: single corridor test room
- `EnemyBasic.tscn`: first enemy
- `Elevator.tscn`: room transition

## Implementation shape
- Keep the slice small and direct.
- Build player control before enemy complexity.
- Use one room to validate the full loop before expanding content.

## Success criteria
- The game boots into the slice.
- The player can traverse the corridor and survive one combat encounter.
- The elevator transitions cleanly to the next area.
