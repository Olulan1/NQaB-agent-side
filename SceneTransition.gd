extends Node

var pending_spawn_name: String = ""
var player_max_health: int = 5
var player_health: int = 5


func set_pending_spawn_name(spawn_name: String) -> void:
	pending_spawn_name = spawn_name


func consume_pending_spawn_name() -> String:
	var spawn_name := pending_spawn_name
	pending_spawn_name = ""
	return spawn_name


func set_player_health(value: int) -> void:
	player_health = clampi(value, 0, player_max_health)


func reset_player_health() -> void:
	player_health = player_max_health
