extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var left_spawn: Marker2D = $LeftSpawn


func _ready() -> void:
	var pending_spawn_name := SceneTransition.consume_pending_spawn_name()
	if pending_spawn_name == "floor1_left":
		player.global_position = left_spawn.global_position
