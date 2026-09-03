# Laser Offset Shortcuts

Use these two lines in `Player.gd` when you want to tune the laser projectile spawn by hand:

- Standing laser origin: [Player.gd](/Users/lani/nqab/Player.gd#L51) and specifically `STANDING_WEAPON_MUZZLE_OFFSETS[3]`
- Crouch laser origin: [Player.gd](/Users/lani/nqab/Player.gd#L57) and specifically `CROUCH_WEAPON_MUZZLE_OFFSETS[3]`

Current editable values:

- Standing: `Vector2(30.0, -6.0)`
- Crouch: `Vector2(30.0, 2.0)`

If you want to nudge them again:

- Move left by lowering the X value.
- Move up by lowering the Y value.
- For crouch only, edit `CROUCH_WEAPON_MUZZLE_OFFSETS[3]`.
- For standing only, edit `STANDING_WEAPON_MUZZLE_OFFSETS[3]`.
