extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var left_spawn: Marker2D = $LeftSpawn
@onready var right_spawn: Marker2D = $RightSpawn


func _ready() -> void:
	var pending_spawn_name := SceneTransition.consume_pending_spawn_name()
	if pending_spawn_name == "floor1_left":
		player.global_position = left_spawn.global_position
	elif pending_spawn_name == "floor1_right":
		player.global_position = right_spawn.global_position
