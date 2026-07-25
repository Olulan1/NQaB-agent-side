extends Area2D

@export var speed: float = 640.0
@export var lifetime: float = 1.2

var direction: int = 1


func set_direction(value: int) -> void:
	direction = 1 if value >= 0 else -1
	scale.x = abs(scale.x) * direction


func _physics_process(delta: float) -> void:
	position.x += speed * direction * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
