extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var left_spawn: Marker2D = $LeftSpawn


func _ready() -> void:
	if SceneTransition.consume_pending_spawn_name() == "intro02_left":
		player.global_position = left_spawn.global_position
