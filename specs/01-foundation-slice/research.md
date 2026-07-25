# Research

## Goal
Validate that a small Godot slice can prove the core corridor-action loop for *Not Quite a Box* before any larger content is built.

## Source context
- `dev-thoughts/NQaB base design.md`

## What the slice must test
- Player movement in a 3-tile-tall corridor
- Jumping and crouching as combat movement, not just traversal
- One ranged attack with clear hit feedback
- One basic enemy that forces reaction
- One room-to-room transition through an elevator or exit trigger

## Current feasibility read
- The project is feasible as a Godot 2D action game.
- The current scope is small enough to build a playable proof-of-concept without needing the full 20-floor tower.
- The first slice should be treated as a mechanics test, not a content test.
- The game should remain strictly 2D.

## Main risks
- The corridor may be too narrow or too flat if jump/crouch timing is not readable.
- Too many mechanics too early would obscure whether the core loop is actually fun.
- If the player, enemy, and transition are all overbuilt at once, iteration will slow down.
- A single enemy type may be enough for the slice, but only if its behavior creates clear pressure.

## Recommended proof order
1. Make the room launchable from the project entry scene.
2. Add the player controller with movement, jump, crouch, and blaster fire.
3. Add one enemy and verify damage exchange.
4. Add the elevator or exit transition.
5. Play through the room end to end and decide if the loop deserves expansion.

## Open questions
- Is the corridor width comfortable for jump/crouch combat?
- Does the blaster feel readable at the intended pace?
- Is one enemy enough to prove the pacing of the slice?
- Does the elevator transition preserve momentum, or interrupt it?
