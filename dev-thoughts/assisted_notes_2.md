# assisted_notes_2

Floor2-1 changes:

1. Remove all turrets from `Floor2-1`.
2. Add two new enemies using the reference images:
   - `VolatileSpike`
   - `Dasher`
3. Treat the reference art as background-removed / transparent cutouts before use.
4. Use the shorthand names in continuity notes and changelog:
   - `VolatileSpike` = `VS`
   - `Dasher` = `Dasher`

VolatileSpike requirements:

- Static until shot by the player.
- When shot, move straight upward until it hits the ceiling.
- After reaching the ceiling, follow the outline of the scene collisions.
- Treat gate objects such as `ExitElevator` and `NextScreen` as obstacles while tracing.
- Stay inside the playable area and do not overlap the gates.
- Continue tracing for 20 seconds.
- After 20 seconds, return directly to the original position.

Dasher requirements:

- Grounded enemy.
- Dash left or right every 2 seconds.
- Dash distance: 4 tiles.
- Small enough for a normal player jump to clear.
- Use turret-style knockback on player contact.
- Health: 2.
- Never move beyond the screen bounds.

Implementation notes:

- Keep the scene strictly 2D.
- Preserve the current Floor2-1 layout aside from removing turrets and adding the two new enemies.
- Keep the behavior self-contained in the enemy scenes/scripts.
