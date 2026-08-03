extends CharacterBody2D

@export var speed: float = 96.0
@export var crouch_speed: float = 64.0
@export var jump_velocity: float = -360.0
@export var sprint_multiplier: float = 3.0
@export var fall_gravity: float = 400.0
@export var knockback_horizontal_speed: float = 160.0
@export var knockback_vertical_speed: float = -160.0
@export var knockback_duration: float = 0.14
@export var projectile_scene: PackedScene = preload("res://Projectile.tscn")
@export var projectile_spawn_offset: Vector2 = Vector2(18.0, -8.0)
@export var crouched_projectile_spawn_offset: Vector2 = Vector2(18.0, 2.0)
@export var fire_cooldown: float = 0.18

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual_root: Node2D = $VisualRoot
@onready var muzzle: Marker2D = $Muzzle

var facing: int = 1
var fire_timer: float = 0.0
var crouching: bool = false
var jump_was_held: bool = false
var weak_jump_was_held: bool = false
var fire_was_held: bool = false
var knockback_time_left: float = 0.0


func _physics_process(delta: float) -> void:
	if fire_timer > 0.0:
		fire_timer = maxf(fire_timer - delta, 0.0)
	if knockback_time_left > 0.0:
		knockback_time_left = maxf(knockback_time_left - delta, 0.0)

	var left_held := Input.is_physical_key_pressed(KEY_A)
	var right_held := Input.is_physical_key_pressed(KEY_D)
	var horizontal := 0.0
	if knockback_time_left <= 0.0:
		if left_held != right_held:
			horizontal = -1.0 if left_held else 1.0
			facing = -1 if left_held else 1

	crouching = Input.is_physical_key_pressed(KEY_S)
	_update_crouch_state()
	_update_muzzle_position()

	if not is_on_floor():
		velocity.y += fall_gravity * delta

	var jump_held := Input.is_physical_key_pressed(KEY_SPACE)
	var weak_jump_held := Input.is_physical_key_pressed(KEY_W)
	if is_on_floor() and weak_jump_held and not weak_jump_was_held and not (jump_held and not jump_was_held):
		velocity.y = jump_velocity * 0.5
	elif is_on_floor() and jump_held and not jump_was_held:
		velocity.y = jump_velocity
	jump_was_held = jump_held
	weak_jump_was_held = weak_jump_held

	if knockback_time_left <= 0.0:
		var move_speed := crouch_speed if crouching else speed
		if Input.is_key_pressed(KEY_SHIFT):
			move_speed *= sprint_multiplier
		velocity.x = horizontal * move_speed

	var fire_held := Input.is_physical_key_pressed(KEY_E)
	if fire_held and not fire_was_held:
		_try_fire()
	fire_was_held = fire_held

	move_and_slide()


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


func apply_projectile_knockback(_source_position: Vector2, _projectile_velocity: Vector2) -> void:
	_apply_knockback(_source_position, knockback_horizontal_speed, knockback_vertical_speed, knockback_duration)


func apply_turret_knockback(source_position: Vector2) -> void:
	_apply_knockback(source_position, knockback_horizontal_speed, knockback_vertical_speed, knockback_duration)


func _apply_knockback(source_position: Vector2, horizontal_speed: float, vertical_speed: float, duration: float) -> void:
	var dx := global_position.x - source_position.x
	var horizontal_push: float
	if absf(dx) >= 4.0:
		horizontal_push = 1.0 if dx > 0.0 else -1.0
	else:
		horizontal_push = -1.0 if facing > 0 else 1.0

	velocity.x = horizontal_push * horizontal_speed
	velocity.y = minf(velocity.y, vertical_speed)
	knockback_time_left = duration
