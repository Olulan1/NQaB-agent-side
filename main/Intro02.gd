extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var left_spawn: Marker2D = $LeftSpawn
@onready var middle_spawn: Marker2D = $MiddleSpawn


func _ready() -> void:
	var pending_spawn_name := SceneTransition.consume_pending_spawn_name()
	if pending_spawn_name == "intro02_left":
		player.global_position = left_spawn.global_position
	elif pending_spawn_name == "intro02_middle":
		player.global_position = middle_spawn.global_position
