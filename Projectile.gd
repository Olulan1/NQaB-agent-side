extends Area2D

@export var speed: float = 640.0
@export var lifetime: float = 1.2
@export var damage: int = 1
@export var source_is_player: bool = false

var travel_velocity: Vector2 = Vector2.ZERO
var direction: int = 1


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func set_direction(value: int) -> void:
	direction = 1 if value >= 0 else -1
	travel_velocity = Vector2(speed * direction, 0.0)
	scale.x = abs(scale.x) * direction


func set_downward() -> void:
	direction = 1
	travel_velocity = Vector2(0.0, speed)
	scale.x = abs(scale.x)


func _physics_process(delta: float) -> void:
	global_position += travel_velocity * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if source_is_player and body.name == "Player":
		queue_free()
		return

	if source_is_player and body.has_method("apply_player_projectile_hit"):
		body.call("apply_player_projectile_hit", damage, global_position, travel_velocity)
		queue_free()
		return

	if not source_is_player and body.has_method("apply_enemy_projectile_hit"):
		body.call("apply_enemy_projectile_hit", damage, global_position, travel_velocity)
		queue_free()
		return

	if body is StaticBody2D or body is TileMapLayer or body is TileMap:
		queue_free()
