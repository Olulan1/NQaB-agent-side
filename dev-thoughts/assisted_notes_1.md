# Assisted Notes 1

## Purpose

Define how crouching should affect the player visuals and weapon firing origin so that standing and crouching use separate pose assets and the projectile source stays aligned with the weapon tip.

## Main idea

- The player must have one set of standing visuals and one set of crouching visuals.
- Crouching should not be simulated by reusing the standing pose with a small offset.
- The weapon image used while standing and the weapon image used while crouching should be separate assets.
- The projectile spawn point should match the visible weapon tip for the current pose.

## Expected behavior

### Standing

- Use the standing body pose.
- Use the standing weapon image.
- Use the standing weapon position.
- Fire projectiles from the standing weapon origin.

### Crouching

- Use the crouching body pose.
- Use the crouching weapon image.
- Use the crouching weapon position.
- Fire projectiles from the crouching weapon origin.

## Implementation map for `Player.gd`

- Keep the standing weapon position values unchanged.
- Add a second crouching weapon position set.
- Add a second crouching weapon image set.
- Switch between standing and crouching weapon assets based on the crouch state.
- Switch between standing and crouching projectile spawn offsets based on the crouch state.
- Keep the muzzle/projectile origin visually tied to the current weapon tip, not to a single shared location.

## Notes for Ralph Specum

- Preserve the current standing behavior.
- Add crouch-specific assets instead of overwriting standing assets.
- Keep the standing and crouching positions independent.
- Make sure the projectile source point uses the same pose logic as the visible weapon image.

## Acceptance criteria

- Standing weapon art remains unchanged.
- Crouching uses a separate weapon art.
- Standing and crouching weapons do not share one universal position.
- Projectile spawn position matches the weapon tip in both poses.
- The result is easy to tune later by changing the standing and crouching values separately.

## Extra note

- If the crouching weapon position is already correct in vector terms, a second image set may not be needed.
- If the crouching weapon position is not correct after vector tuning, try image manipulation so the weapon art itself places the firing origin lower inside the image.
- Ralph Specum should keep this in mind while implementing and while checking the crouch pose in-game.
