extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var left_spawn: Marker2D = get_node_or_null("LeftSpawn") as Marker2D
@onready var right_spawn: Marker2D = get_node_or_null("RightSpawn") as Marker2D
@onready var elevator_return: Marker2D = get_node_or_null("ElevatorReturn") as Marker2D


func _ready() -> void:
	var pending_spawn_name := SceneTransition.consume_pending_spawn_name()
	if pending_spawn_name == "LeftSpawn" and left_spawn != null:
		player.global_position = left_spawn.global_position
	elif pending_spawn_name == "RightSpawn" and right_spawn != null:
		player.global_position = right_spawn.global_position
	elif pending_spawn_name == "ElevatorReturn" and elevator_return != null:
		player.global_position = elevator_return.global_position + Vector2(0.0, 12.0)
