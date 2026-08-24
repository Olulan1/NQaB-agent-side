# Potential Answers

This file collects information-only notes for the `di5.md` follow-up work.

## Decision format

For implementation choices, use only one of these responses:

- `Yes`
- `No`
- `However` followed by a short explanation

## Current items in scope

### 1. Crouching sprite that does not phase into the ground

Best path:

- `Yes`: keep the player root and collider fixed, and swap only the visible crouch pose with an offset.
- `No`: keep the current crouch behavior unchanged.
- `However`: separate the visual sprite from the collision shape and animate the visual root downward less than the collider change.

## User choices

- Crouching sprite: `No`
- Separate head/body: `Yes`
- Best sprite path: `However`
- Weapon switching: `Yes`
- Ammo UI: `Yes`

### 2. Separate head and body parts

Best path:

- `Yes`: split the player into a visual hierarchy with `Body` and `Head` nodes under a shared root.
- `No`: keep one combined sprite and simulate height changes through scaling or cropping.
- `However`: separate only the parts needed for overlays and weapon-height alignment first.

### 3. Best player sprite implementation path

Best path:

- `Yes`: use a layered `Node2D` / `Sprite2D` structure with a fixed collision root and swappable visual children.
- `No`: keep a single sprite and change frames only.
- `However`: migrate to layered parts only after the current movement and combat behavior is stable.

### 4. Weapon switching system

Best path:

- `Yes`: drive weapons from a small data table plus a single input handler on `q`.
- `No`: hardcode each weapon directly into the player script.
- `However`: implement default fire first, then add burst, shotgun, and laser as separate weapon entries.

### 5. Ammo UI below health

Best path:

- `Yes`: render bullet icons in a HUD row under the health display, with counts changing by weapon.
- `No`: keep ammo invisible because it is unlimited.
- `However`: show placeholder counts first and replace them with the `ammo.png` icon after the weapon system exists.
