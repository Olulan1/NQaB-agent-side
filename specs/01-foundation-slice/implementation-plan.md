# Implementation Plan

## Purpose
Execute the first playable slice of *Not Quite a Box* as a minimal, tunable 3-floor Godot experience.

## Source context
- `dev-thoughts/NQaB base design.md`

## Execution rules
- Keep the game strictly 2D.
- Do not use non-2D editor systems.
- Keep Floors 1-3 as the only playable scope for this slice.
- Keep Floor 1 movement unobstructed.
- Prefer simple, tuneable room layouts over extra systems.
- If movement feels hindered, fix the room before adding new mechanics.

## Order of work

1. **Floor 1 movement gate**
   - Ensure the project launches into Floor 1.
   - Ensure the player can move freely left and right.
   - Ensure the room layout does not block basic movement.

2. **Player baseline**
   - Add jump, crouch, and blaster fire.
   - Keep the controller small and readable.
   - Keep controls responsive enough to tune later.

3. **Floor 2 pressure check**
   - Add one simple enemy or obstacle.
   - Preserve movement clarity.
   - Add only enough pressure to test pacing.

4. **Floor 3 loop closure**
   - Add the third floor.
   - Add the minimal transition needed to complete the first 3-floor sequence.
   - Keep the final floor concise and tuneable.

5. **Readability pass**
   - Run the full 3-floor slice.
   - Tweak spacing, collision, and pacing only where movement or readability suffers.
   - Do not add new systems during tuning.

## Acceptance summary
- Floor 1 loads and movement is unhindered.
- The player can move, jump, crouch, and shoot.
- Floor 2 adds light pressure without breaking flow.
- Floor 3 closes the loop cleanly.
- The slice remains minimal, readable, and tuneable.

## Current Implementation Tasks
- Keep the game strictly 2D and preserve the existing main plan above.
- Rename `Floor01.tscn` to `Intro01.tscn`.
- Create `Intro02.tscn` from the current `Intro01` layout, with one extra grid square of floor on the left of the visible background while staying connected to the existing floor.
- Add a seamless scene transition at the end of `Intro01` that transports the player to the start of `Intro02.tscn`.
- Add a grey vertical background wall in the middle of `Intro02`.
- Add centered Roboto text in `Intro02` at size 42 and 80% opacity above the wall, spanning about four grid squares.
- Add a grey wall in `Intro02` that blocks forward movement and is higher than the player can jump.
- Keep the current work focused on the first 3 floors only.
