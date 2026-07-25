extends CharacterBody2D

@export var speed: float = 240.0
@export var crouch_speed: float = 140.0
@export var jump_velocity: float = -420.0
@export var gravity: float = 1400.0
@export var projectile_scene: PackedScene = preload("res://Projectile.tscn")
@export var projectile_spawn_offset: Vector2 = Vector2(18.0, -8.0)
@export var crouched_projectile_spawn_offset: Vector2 = Vector2(18.0, -2.0)
@export var fire_cooldown: float = 0.18

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var body: Polygon2D = $Body
@onready var muzzle: Marker2D = $Muzzle

var facing: int = 1
var fire_timer: float = 0.0
var crouching: bool = false


func _physics_process(delta: float) -> void:
	if fire_timer > 0.0:
		fire_timer = maxf(fire_timer - delta, 0.0)

	var horizontal := Input.get_axis("ui_left", "ui_right")
	if horizontal < 0.0:
		facing = -1
	elif horizontal > 0.0:
		facing = 1

	crouching = Input.is_action_pressed("ui_down")
	_update_crouch_state()
	_update_muzzle_position()

	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor() and Input.is_action_just_pressed("ui_up"):
		velocity.y = jump_velocity

	var move_speed := crouch_speed if crouching else speed
	velocity.x = horizontal * move_speed

	if Input.is_action_just_pressed("ui_accept"):
		_try_fire()

	move_and_slide()


func _update_crouch_state() -> void:
	var shape := collision_shape.shape as RectangleShape2D
	if shape == null:
		return

	if crouching:
		shape.size = Vector2(24.0, 32.0)
		body.scale = Vector2(1.0, 0.72)
		collision_shape.position = Vector2(0.0, 8.0)
	else:
		shape.size = Vector2(24.0, 48.0)
		body.scale = Vector2.ONE
		collision_shape.position = Vector2.ZERO


func _update_muzzle_position() -> void:
	var offset := crouched_projectile_spawn_offset if crouching else projectile_spawn_offset
	muzzle.position = Vector2(offset.x * facing, offset.y)


func _try_fire() -> void:
	if fire_timer > 0.0:
		return

	fire_timer = fire_cooldown
	var projectile := projectile_scene.instantiate() as Area2D
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = muzzle.global_position
	if projectile.has_method("set_direction"):
		projectile.call("set_direction", facing)
