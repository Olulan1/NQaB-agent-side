extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var boss: Floor3_3Boss = $Boss
@onready var left_spawn: Marker2D = $LeftSpawn
@onready var right_spawn: Marker2D = $RightSpawn

var boss_dead: bool = false


func _ready() -> void:
	if boss != null:
		boss.tree_exited.connect(_on_boss_tree_exited)
	var pending_spawn_name := SceneTransition.consume_pending_spawn_name()
	if pending_spawn_name == "floor1_left" or pending_spawn_name == "LeftSpawn":
		player.global_position = left_spawn.global_position
	elif pending_spawn_name == "floor1_right" or pending_spawn_name == "RightSpawn":
		player.global_position = right_spawn.global_position


func _on_boss_tree_exited() -> void:
	boss_dead = true
