extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var right_spawn: Marker2D = $RightSpawn


func _ready() -> void:
	if SceneTransition.consume_pending_spawn_name() == "intro01_right":
		player.global_position = right_spawn.global_position
