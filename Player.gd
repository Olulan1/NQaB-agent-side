extends CharacterBody2D

@export var speed: float = 96.0
@export var crouch_speed: float = 64.0
@export var jump_velocity: float = -360.0
@export var gravity: float = 1200.0
@export var projectile_scene: PackedScene = preload("res://Projectile.tscn")
@export var projectile_spawn_offset: Vector2 = Vector2(18.0, -8.0)
@export var crouched_projectile_spawn_offset: Vector2 = Vector2(18.0, -2.0)
@export var fire_cooldown: float = 0.18

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual_root: Node2D = $VisualRoot
@onready var muzzle: Marker2D = $Muzzle

var facing: int = 1
var fire_timer: float = 0.0
var crouching: bool = false


func _ready() -> void:
	_configure_inputs()


func _physics_process(delta: float) -> void:
	if fire_timer > 0.0:
		fire_timer = maxf(fire_timer - delta, 0.0)

	var horizontal := Input.get_axis("move_left", "move_right")
	if horizontal < 0.0:
		facing = -1
	elif horizontal > 0.0:
		facing = 1

	crouching = Input.is_action_pressed("crouch")
	_update_crouch_state()
	_update_muzzle_position()

	if not is_on_floor():
		velocity.y += gravity * delta

	if is_on_floor() and Input.is_action_just_pressed("jump"):
		velocity.y = jump_velocity

	var move_speed := crouch_speed if crouching else speed
	velocity.x = horizontal * move_speed

	if Input.is_action_just_pressed("fire"):
		_try_fire()

	move_and_slide()


func _configure_inputs() -> void:
	_bind_key("move_left", KEY_W)
	_bind_key("move_right", KEY_D)
	_bind_key("jump", KEY_SPACE)
	_bind_key("crouch", KEY_S)
	_bind_key("fire", KEY_E)


func _bind_key(action_name: StringName, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)
	InputMap.action_erase_events(action_name)
	var event := InputEventKey.new()
	event.physical_keycode = keycode
	InputMap.action_add_event(action_name, event)


func _update_crouch_state() -> void:
	var shape := collision_shape.shape as RectangleShape2D
	if shape == null:
		return

	if crouching:
		shape.size = Vector2(20.0, 28.0)
		visual_root.position = Vector2(0.0, 6.0)
		collision_shape.position = Vector2(0.0, 6.0)
	else:
		shape.size = Vector2(20.0, 40.0)
		visual_root.position = Vector2.ZERO
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
