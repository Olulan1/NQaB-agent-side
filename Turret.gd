extends StaticBody2D

@export var projectile_scene: PackedScene = preload("res://Projectile.tscn")
@export var fire_interval: float = 1.0
@export var start_delay: float = 0.0
@export var max_health: int = 5
@export var projectile_damage: int = 1
@export var projectile_speed: float = 640.0
@export var aim_at_player: bool = false
@export var fire_left_only: bool = false
@export var projectile_spawn_offset: Vector2 = Vector2(0.0, 20.0)
@export var player_path: NodePath = NodePath("../Player")

@onready var fire_timer: Timer = $FireTimer
@onready var knockback_area: Area2D = $KnockbackArea

var health: int


func _ready() -> void:
	health = max_health
	fire_timer.wait_time = fire_interval
	fire_timer.timeout.connect(_fire)
	knockback_area.body_entered.connect(_on_knockback_area_body_entered)
	fire_timer.stop()
	if start_delay > 0.0:
		await get_tree().create_timer(start_delay).timeout
	if not is_inside_tree():
		return
	fire_timer.start()


func _fire() -> void:
	var projectile := projectile_scene.instantiate() as Area2D
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position + projectile_spawn_offset
	_configure_turret_projectile(projectile)
	projectile.set("speed", projectile_speed)
	projectile.set("damage", projectile_damage)
	projectile.set("source_is_player", false)
	if aim_at_player:
		var player := get_node_or_null(player_path) as Node2D
		var direction := 1
		if player != null and player.global_position.x < global_position.x:
			direction = -1
		if projectile.has_method("set_direction"):
			projectile.call("set_direction", direction)
	elif fire_left_only:
		if projectile.has_method("set_direction"):
			projectile.call("set_direction", -1)
	elif projectile.has_method("set_downward"):
		projectile.call("set_downward")


func _configure_turret_projectile(projectile: Area2D) -> void:
	projectile.collision_mask = 0
	projectile.set_collision_mask_value(1, true)


func _on_knockback_area_body_entered(body: Node2D) -> void:
	if body.has_method("apply_turret_contact_damage"):
		body.call("apply_turret_contact_damage", global_position)
	if body.has_method("apply_turret_knockback"):
		body.call("apply_turret_knockback", global_position)


func apply_player_projectile_hit(damage: int, _source_position: Vector2, _projectile_velocity: Vector2, _weapon_kind: int = 0) -> void:
	health = maxi(health - max(1, damage), 0)
	if health <= 0:
		queue_free()
