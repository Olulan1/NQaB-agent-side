extends Area2D

@export var speed: float = 640.0
@export var lifetime: float = 1.2
@export var damage: int = 1
@export var source_is_player: bool = false
@export var free_on_hit: bool = true
@export var max_distance: float = 0.0
@export var weapon_kind: int = 0
@export var damage_profile_durations: PackedFloat32Array = PackedFloat32Array()
@export var damage_profile_values: PackedInt32Array = PackedInt32Array()

var travel_velocity: Vector2 = Vector2.ZERO
var direction: int = 1
var travel_distance: float = 0.0
var age: float = 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func set_direction(value: int) -> void:
	direction = 1 if value >= 0 else -1
	set_velocity(Vector2(speed * direction, 0.0))
	scale.x = abs(scale.x) * direction


func set_downward() -> void:
	direction = 1
	set_velocity(Vector2(0.0, speed))
	scale.x = abs(scale.x)


func set_velocity(value: Vector2) -> void:
	travel_velocity = value
	if absf(travel_velocity.x) >= 0.001:
		direction = 1 if travel_velocity.x >= 0.0 else -1
		scale.x = abs(scale.x) * direction


func set_damage_profile(durations: PackedFloat32Array, values: PackedInt32Array) -> void:
	damage_profile_durations = durations
	damage_profile_values = values
	_sync_profile_damage()


func _physics_process(delta: float) -> void:
	age += delta
	if damage_profile_values.size() > 0:
		_sync_profile_damage()
	global_position += travel_velocity * delta
	travel_distance += travel_velocity.length() * delta
	if max_distance > 0.0 and travel_distance >= max_distance:
		queue_free()
		return
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _sync_profile_damage() -> void:
	if damage_profile_values.is_empty():
		return

	var elapsed := age
	var cumulative_time := 0.0
	for i in range(min(damage_profile_values.size(), damage_profile_durations.size())):
		cumulative_time += damage_profile_durations[i]
		if elapsed <= cumulative_time:
			damage = damage_profile_values[i]
			return
	damage = damage_profile_values[damage_profile_values.size() - 1]


func _on_body_entered(body: Node) -> void:
	if source_is_player and body.name == "Player":
		if free_on_hit:
			queue_free()
		return

	if source_is_player and body.has_method("apply_player_projectile_hit"):
		body.call("apply_player_projectile_hit", damage, global_position, travel_velocity, weapon_kind)
		if free_on_hit:
			queue_free()
		return

	if not source_is_player and body.has_method("apply_enemy_projectile_hit"):
		body.call("apply_enemy_projectile_hit", damage, global_position, travel_velocity)
		if free_on_hit:
			queue_free()
		return

	if body is StaticBody2D or body is TileMapLayer or body is TileMap:
		queue_free()
