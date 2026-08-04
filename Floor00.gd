extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var elevator_return: Marker2D = $ElevatorReturn


func _ready() -> void:
	var pending_spawn_name := SceneTransition.consume_pending_spawn_name()
	if pending_spawn_name == "ElevatorReturn":
		player.global_position = elevator_return.global_position + Vector2(0.0, 12.0)
