Change "Floor00".gd and all its dependencies, including its filename and .stcn file, renaming them to Floor01."gd"/"tscn". With the exception of Intro02, where the dependencies there should link to a NEWLY CREATED Intro00.gd and .tscn, that is an exact copy of the current Floor00, but without an exit elevator or exit elevator caption.

On the newly created Floor00, remove all objects to the far right of the player, allowing them to teleport to Floor01 by walking offscreen, the same as any level prior. As such, all features related to "ExitElevator" should be deleted on this new Floor. 

Floor00 should NOT be conflated with Intro00.

On the newly created Floor00, using the destructible property of the turrets on Floor11/12, set up walls that fully obstruct the player's progress that can be destroyed if shot once.

Use a text label in a similar placement to the ones placed on Intro00 and Intro02 to explain that the player should use E to fire.
It should explicitly state "Press 'E' to fire."


After the succesful enstation of Floor00 and Floor01 as SEPARATE FLOORS, linked Exit and Return Gate Teleporters, double check all scenes that are currently implemented are linked in this chronology by their gates/barriers:

Intro00/01 - Intro02 - Floor00 - Floor01 - Floor1-1 - Floor1-2

After all of this, explain why Intro00 and Intro01 are dependent even though only one is ever traversed by the player actively.