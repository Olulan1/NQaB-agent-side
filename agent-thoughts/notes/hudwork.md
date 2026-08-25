# HUD Work Notes

This note records the answer to: how to manually access the size of the HUD items and weapons.

## What to edit

- HP / health count:
  - `max_health` is at [Player.gd](../../Player.gd#L42)
  - `health` is at [Player.gd](../../Player.gd#L68)
  - `_health_cells` is at [Player.gd](../../Player.gd#L77)
  - The health bar is built in `_build_health_ui()` at [Player.gd](../../Player.gd#L325)

- Health box size:
  - `frame.size = Vector2(176.0, 44.0)` at [Player.gd](../../Player.gd#L345)
  - `content.size = Vector2(160.0, 28.0)` at [Player.gd](../../Player.gd#L364)
  - `cell.custom_minimum_size = Vector2(28.0, 28.0)` at [Player.gd](../../Player.gd#L379)

- Ammo row:
  - `_ammo_icons` is at [Player.gd](../../Player.gd#L78)
  - `ammo_frame.size = Vector2(176.0, 28.0)` at [Player.gd](../../Player.gd#L409)
  - `ammo_row.add_theme_constant_override("separation", 6)` at [Player.gd](../../Player.gd#L430)
  - `icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE` at [Player.gd](../../Player.gd#L439)
  - `icon.custom_minimum_size = Vector2(20.0, 20.0)` at [Player.gd](../../Player.gd#L440)

- Weapon selector:
  - `_weapon_boxes` is at [Player.gd](../../Player.gd#L79)
  - `weapon_frame.size = Vector2(176.0, 38.0)` at [Player.gd](../../Player.gd#L448)
  - `weapon_row.add_theme_constant_override("separation", 6)` at [Player.gd](../../Player.gd#L467)
  - `box.custom_minimum_size = Vector2(30.0, 30.0)` at [Player.gd](../../Player.gd#L475)
  - `icon.custom_minimum_size = Vector2(24.0, 24.0)` at [Player.gd](../../Player.gd#L497)

- Held weapon on the player:
  - `weapon_icon` is at [Player.gd](../../Player.gd#L65)
  - `STANDING_WEAPON_ICON_POSITION` is at [Player.gd](../../Player.gd#L33)
  - `CROUCH_WEAPON_ICON_POSITION` is at [Player.gd](../../Player.gd#L34)
  - `_sync_weapon_ui()` sets the visible weapon icon position at [Player.gd](../../Player.gd#L511)

## How to adjust manually

- Make the HP HUD bigger or smaller by changing the `HealthFrame`, `HealthContent`, and `Cell` sizes.
- Make ammo icons smaller by changing the ammo `TextureRect` minimum size in the ammo loop.
- Make the ammo art ignore its giant source canvas by setting `expand_mode = TextureRect.EXPAND_IGNORE_SIZE`.
- Increase or reduce the visible ammo size by editing `icon.custom_minimum_size` in [Player.gd](../../Player.gd#L440).
- Make weapon boxes smaller or larger by changing `box.custom_minimum_size`.
- Make the weapon art itself smaller by changing the `icon.custom_minimum_size` inside the weapon loop.
- Move the held weapon closer to or farther from the character by changing `STANDING_WEAPON_ICON_POSITION` and `CROUCH_WEAPON_ICON_POSITION`.
- The HP value shown to the player is controlled by `max_health`, and the current player HP is tracked in `health`.

## Current finding

- The ammo HUD now ignores the PNG's native size and uses `expand_mode = TextureRect.EXPAND_IGNORE_SIZE` with a small `custom_minimum_size`.
- The actual visible bullet art still lives in [ammo.png](../../dev-thoughts/imgs/ammo.png); if it ever looks too large again, check the import behavior plus the `TextureRect` settings first.
- The latest ammo artwork replacement makes the bullet fill more of its canvas, so the row should read larger without changing the HUD container geometry.
