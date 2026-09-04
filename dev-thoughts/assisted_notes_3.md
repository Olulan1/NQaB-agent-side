# Assisted Notes 3

1. Copy `Floor1-3`'s `PrevScreenReturn` onto `Floor2-3`, then link it to the `RightSpawn` of `Floor2-2`.
2. Duplicate `Floor2-3` and call it `Floor3-3`, but remove all obstacles and only keep the `ExitElevator` at the end.
3. Place the `Floor3-3Boss` enemy stored in `characterAssets` in the middle of `Floor3-3`.
4. Make the boss enemy's main color blue.
5. Give the boss 75 health.
6. Give the boss a 5-section health bar that is visible to the player, with no visible section distinctions, and make it deplete from 75 health as the player shoots it.
7. Place a copy of the black-and-red `Barrier3` from `Floor01` in front of the `ExitElevator`, make it a child of `Floor3-3Boss`, and keep it indestructible unless the boss dies.
8. On either side of the boss, place two portals based on `dev-thoughts/imgs/portal.png` and `dev-thoughts/imgs/portalClosed.png`, and let the player teleport between them by pressing `X` while in contact with one.
9. After a teleport, start an 8 second cooldown where the portals cannot be used, and temporarily swap them to the closed image.
10. Make the caption above the open portals say `Press X to teleport!`, and hide that caption while the portal is on cooldown.
11. Give `Floor3-3Boss` an attack where it charges at the player every 7 seconds, the same distance as a dasher, with a random chance to charge in the opposite direction.
12. Make sure the boss can shoot in the direction of the player without any minimum distance requirement.
13. Make the boss bullets red.
