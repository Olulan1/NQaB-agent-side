Title: Not Quite a Box
Genre: NOT a metroidvania, reaction-based corridor action game.
Tags: Linear, Uniform level design, Fast-paced, Shooter, 16-bit, Action, Side scroller

Core gameplay loop: Player ascends an elevator to a floor. Floor contains aliens, rogue machinery or both, attempting to kill the player. Player must move forward through the 2D, tunnel-like interior levels, which only have differences of enemies and obstacles, maybe color if explicitly communicated as such, but for now, not the case.

Lore: Player character is a space agent who has had his organisation's tower overrun by aliens, and the machinery hacked unanimously to target its agents or other humanoids. Player must avoid or destroy all enemies on the floor on his way to the elevator, which is a straight shot forward, but there might be 3-5 loading screens depending on the floor he is on, to get to the elevator. Total floors: 20

Player
- 5 hitpoints
- 1 life (a capsule can be picked up every three levels by killing every enemy on the floor to extend this)
- Movement abilities:
	  -  Crouch
	  - Jump
	  - Ceiling cling (only if item picked up on floor 5 or so)
- Equipment: 
	- Burst pistol/blaster (shoots intercardinally, but whether it is screen relative or player relative is to be decided, 1hp of damage, range of 8 tiles) 
	- Shotgun (Shoots up, down and while crouching/standing/jumping, forward, for 2HP of dmg, with a range of 3 tiles)
	- Railgun (one shot per floor, charges in elevator, but upper floors reset unless cleared, 5HP of dmg, range of 13 tiles, can only be shot straight forward, crouching, jumping or standing)
	- Grenade (3 per floor, covers a 3 by 2 tile radius)
	- (Pick-up) Disposable Shields that block your front(x3, x5 on floors 15-20)
	- (Pick-up) Med Kit that heals you to full health
	- (Pick-up) 

Gameplay Loop:
- Kill enemies on a few screens of a floor
- Collect powerups or ammo
- Beat boss at the end of certain floors
- Ascend elevator to next floor
	- Can return to previous floors, but they are only as cleared as they were left
	- No button required to ascend, button press required to descend

Controls:
- Arrow key/WASD movement
- Down to crouch
- Space to jump
- E to fire
- Q to cycle
- Z to interact (usuallly with elevators)
- Combinations of directional keys can be held to aim blaster intercardinally, for better coverage
  

Levels:
- Each "level" is a floor of the tower, with multiple screens per floor
- 3 tiles (aka units) tall
- Blue tube like background, meant to be a window but is glazed to a degree, and therefore too opaque to be considered as such
- Each screen is about 20 tiles long, with some screens ending earlier depending on how low of a level the player is being given.  
- Elevators ascend in a zigzag pattern, so level 1 you come in from the left, leave from the right, start level 2 from the right, leave from the left, etc
- Option for making levels never flip (visually) may be in settings
- Turrets will be destructible depending on color
- Player has infinite ammo, but not infinite lives
- Blaster rounds take the form of bullets, like pellets, but relatively weak, so that advancing enemies are more fretful to fight
- Blaster can shoot in the intercardinal directions, as long as they hold the correct combo of arrows
- Prior elevators can only be activated if the player presses a certain button, to avoid accidental level mashing, but elevators are automatic on the way out of a level

Enemies so far:
(References - C = Ceiling, F&C = Floor and Ceiling, F = Floor, M = Mid)

- (C) Stationary, one-eyed plant alien that shoots acid downward every 3s

- (F&C) Stationary turret that fires a rubber pellet/rocket/cannonball every 3/4/3 seconds

- (M) Stationary, plant-like turret that fires a a burst of 3 pellets, diagonally up, straight, and down

- (F) Scuttling blue-purple one-eyed alien that crosses toward you at a speed of 1/2 tiles per second (hence, tps)

- (F) End of floor 5 boss, that shoots a burst of rounds straight forward, at the speed of 0.8tps, either at mid or floor height, forcing you to jump or crouch. Moves backward and forward between the 3 tiles in front of the exit, resulting in him preventing you from simply jumping over him to get to the elevator

Powerups and Drops:
- Shields will drop from end of floor bosses ONLY, for a max of 10 shields
- Since the shotgun and blaster have infinite ammo, only the grenades will drop as ammo
	- Thus, 2 grenades have a 20% chance in dropping from monsters, 3 will have a 10% chance
- Bandages (1HP heal) will have a 10% chance of dropping from monsters
- First Aid Kits (3HP heal) will have a 10% chance of dropping from monsters
-  Med Kits (Full HP heal) will have a 10% chance of dropping from monsters

(Note: Only one item can drop at a time, so the priority of whether an item drops is: Grenades, Med Kits, Bandages, First Aid Kits. This means in the instance any of these drops is _true_ after the death of a given alien/monster, the other probabilities after it are not calculated. That, or all probabilities fail, so no item is dropped at all.)

