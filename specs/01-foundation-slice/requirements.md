# Requirements

## Goal
Deliver a minimal but tunable 3-floor Godot slice that proves the core corridor-action loop of *Not Quite a Box*.

## Source context
- `dev-thoughts/NQaB base design.md`

## Functional requirements

- The project must boot directly into the first slice from the main scene.
- The player must be able to move left and right.
- The player must be able to jump.
- The player must be able to crouch.
- The player must be able to fire the starting blaster.
- The slice must contain one short corridor room.
- The slice must contain the first 3 floors of the game as working playable spaces.
- The slice must contain one basic enemy.
- The enemy must be able to damage the player.
- The player must be able to damage or defeat the enemy.
- The slice must include an exit or elevator transition that ends the room cleanly.
- The slice must present enough feedback for the player to understand damage, threat, and transition success.

## Non-functional requirements

- The slice should stay simple enough to iterate on quickly.
- The controls should be readable without adding extra mechanics.
- The room layout should support both forward movement and combat timing.
- The implementation should be small enough to finish before adding the larger tower content.
- The game should remain 2D-only.

## Scope limits

- No full 20-floor content.
- No secondary weapon system yet.
- No complex drops, inventory, or healing economy.
- No backtracking or multi-room branching in the first slice.
- No ceiling-cling item yet.
- No 3D systems or non-2D editor features.

## Success criteria

- The project launches into the first room without manual setup.
- The player can complete a full room loop with movement, combat, and exit transition.
- Floors 1, 2, and 3 can all be played in sequence.
- The slice is simple enough to serve as the base for the next phase of content expansion.
