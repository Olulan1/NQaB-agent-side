extends CharacterBody2D

@export var speed: float = 240.0
@export var gravity: float = 1400.0


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0.0

	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	move_and_slide()
