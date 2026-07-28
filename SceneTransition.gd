extends Node

var pending_spawn_name: String = ""


func set_pending_spawn_name(spawn_name: String) -> void:
	pending_spawn_name = spawn_name


func consume_pending_spawn_name() -> String:
	var spawn_name := pending_spawn_name
	pending_spawn_name = ""
	return spawn_name
