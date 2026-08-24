Steps to be done in correspondence:
1. Create a "RightSpawn" on Floor1-1 that is in a mirrored position to the current LeftSpawn
2. Ensure that the Floor1-2 PrevScreenReturn goes to the RightSpawn of Floor1-1 and not the LeftSpawn.
3. Do not move the LeftSpawn on Floor1-1 from its current position.
4. Create a LeftSpawn and RightSpawn on Floor1-2 in the positions of the LeftSpawn and RightSpawn on Floor1-1

Store a copy of the current player as a variable that is out of use, and begin the changes below.

Find out if it is possible to transition the player to a crouching sprite tgat does not phase into the ground when they crouch

Find out if it is possible to separate the head and body pieces of the player so that they can bre recognized as separate parts of the entity. This can be used to - overlay a different sprite, perform changes of gear on the character or just ensure that weapons and the projectiles they shoot are registering at the correct player height.

Link Intro02 TowerPortal to Floor01 
Link a teleport called Return

See what the best way to implement potential sprites for the player is. 

See, consider and explain how would be best to implement the weapon changing system. The button for switching "fire types" (weapons, before their sprites are implemented)will be q. The types of fire will be: 
1. Default ( current fire, current cooldown)
2. Burst fire (2, 3 shots fired with 0.1s between them and a 1.5s cooldown)
3. Shotgun fire (3, 3, half-size shots that do 3 damage in the first 0.7s, 2 damage in the subsequent 0.8s and 1 damage in the 0.6s after that, despawning after either coming into contact with a wall or an enemy or travelling 10 tiles. They spread out with one going straight, one going on a diagonal line up, and the other down. The gradient of the line is 0.11 from the initial straight line the middle projectile travels), 
4. Laser (A red line that appears for 0.7s over 7 tiles, doing 1 damage, and with a 2s cooldown)

Cooldowns should refer to a hidden timer where a button can be pressed but will not activate the attack. The attack will only be activated ONCE the timer is over AND the button is pressed, and previous presses are not stored as input. 

There should be a small, black box with transparent space in the middle for each of the 4 weapon types, reference images found in /Users/lani/nqab/dev-thoughts under the numbers they're listed with

Also, ammo should be displayed in a similar context to how text is currently displayed. It is currently an unlimited resource, but make a point of ensuring the bullet icon (source: ammo.png). List 6 of them when default is selected, 4 when burst is selected, 2 when shotgun is selected, and 1 when laser is selected. Line the bullets up equidistant below health.