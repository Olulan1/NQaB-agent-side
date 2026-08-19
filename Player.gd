extends CharacterBody2D

@export var speed: float = 96.0
@export var crouch_speed: float = 64.0
@export var jump_velocity: float = -360.0
@export var sprint_multiplier: float = 3.0
@export var fall_gravity: float = 640.0
@export var crouch_fall_gravity_multiplier: float = 2.4
@export var max_health: int = 5
@export var invulnerability_duration: float = 1.5
@export var knockback_horizontal_speed: float = 160.0
@export var knockback_vertical_speed: float = -160.0
@export var knockback_duration: float = 0.14
@export var projectile_damage: int = 1
@export var projectile_scene: PackedScene = preload("res://Projectile.tscn")
@export var projectile_spawn_offset: Vector2 = Vector2(18.0, -8.0)
@export var crouched_projectile_spawn_offset: Vector2 = Vector2(18.0, 2.0)
@export var fire_cooldown: float = 0.18

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visual_root: Node2D = $VisualRoot
@onready var muzzle: Marker2D = $Muzzle

var health: int = 5
var invulnerability_time_left: float = 0.0
var facing: int = 1
var fire_timer: float = 0.0
var crouching: bool = false
var jump_was_held: bool = false
var weak_jump_was_held: bool = false
var fire_was_held: bool = false
var knockback_time_left: float = 0.0
var _health_cells: Array[Panel] = []


func _ready() -> void:
	SceneTransition.player_max_health = max_health
	if SceneTransition.player_health <= 0:
		SceneTransition.reset_player_health()
	health = clampi(SceneTransition.player_health, 0, max_health)
	SceneTransition.set_player_health(health)
	_build_health_ui()
	_sync_health_ui()


func _physics_process(delta: float) -> void:
	if fire_timer > 0.0:
		fire_timer = maxf(fire_timer - delta, 0.0)
	if invulnerability_time_left > 0.0:
		invulnerability_time_left = maxf(invulnerability_time_left - delta, 0.0)
	if knockback_time_left > 0.0:
		knockback_time_left = maxf(knockback_time_left - delta, 0.0)

	var left_held := Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT)
	var right_held := Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)
	var horizontal := 0.0
	if knockback_time_left <= 0.0:
		if left_held != right_held:
			horizontal = -1.0 if left_held else 1.0
			facing = -1 if left_held else 1

	crouching = Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)
	_update_crouch_state()
	_update_muzzle_position()

	if not is_on_floor():
		var gravity_multiplier := crouch_fall_gravity_multiplier if crouching else 1.0
		velocity.y += fall_gravity * gravity_multiplier * delta

	var jump_held := Input.is_physical_key_pressed(KEY_SPACE)
	var weak_jump_held := Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)
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
	projectile.set("damage", projectile_damage)
	projectile.set("source_is_player", true)
	if projectile.has_method("set_direction"):
		projectile.call("set_direction", facing)


func apply_projectile_knockback(_source_position: Vector2, _projectile_velocity: Vector2) -> void:
	_apply_knockback(_source_position, knockback_horizontal_speed, knockback_vertical_speed, knockback_duration)


func apply_turret_knockback(source_position: Vector2) -> void:
	_apply_knockback(source_position, knockback_horizontal_speed, knockback_vertical_speed, knockback_duration)


func apply_enemy_projectile_hit(damage: int, source_position: Vector2, projectile_velocity: Vector2) -> void:
	_take_damage(damage, source_position, projectile_velocity, true)


func apply_turret_contact_damage(source_position: Vector2) -> void:
	_take_damage(1, source_position, Vector2.ZERO, false)


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


func _take_damage(damage: int, source_position: Vector2, projectile_velocity: Vector2, should_knockback: bool) -> void:
	if invulnerability_time_left > 0.0:
		return

	health = maxi(health - maxi(damage, 1), 0)
	SceneTransition.set_player_health(health)
	_sync_health_ui()

	if health <= 0:
		SceneTransition.reset_player_health()
		get_tree().call_deferred("reload_current_scene")
		return

	invulnerability_time_left = invulnerability_duration
	if should_knockback:
		apply_projectile_knockback(source_position, projectile_velocity)


func _build_health_ui() -> void:
	if get_node_or_null("HealthLayer") != null:
		return

	var layer := CanvasLayer.new()
	layer.name = "HealthLayer"
	layer.layer = 10
	add_child(layer)

	var root := Control.new()
	root.name = "HealthRoot"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.position = Vector2(24.0, 24.0)
	root.size = Vector2(176.0, 44.0)
	layer.add_child(root)

	var frame := Panel.new()
	frame.name = "HealthFrame"
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.position = Vector2.ZERO
	frame.size = root.size
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(0.262745, 0.270588, 0.309804, 1.0)
	frame_style.border_color = Color(0.117647, 0.129412, 0.160784, 1.0)
	frame_style.border_width_left = 2
	frame_style.border_width_top = 2
	frame_style.border_width_right = 2
	frame_style.border_width_bottom = 2
	frame_style.corner_radius_top_left = 3
	frame_style.corner_radius_top_right = 3
	frame_style.corner_radius_bottom_left = 3
	frame_style.corner_radius_bottom_right = 3
	frame.add_theme_stylebox_override("panel", frame_style)
	root.add_child(frame)

	var content := Control.new()
	content.name = "HealthContent"
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.position = Vector2(8.0, 8.0)
	content.size = Vector2(160.0, 28.0)
	frame.add_child(content)

	var bar := HBoxContainer.new()
	bar.name = "HealthBar"
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.size = content.size
	bar.add_theme_constant_override("separation", 4)
	content.add_child(bar)

	_health_cells.clear()
	for i in range(max_health):
		var cell := Panel.new()
		cell.name = "Cell%02d" % (i + 1)
		cell.mouse_filter = Control.MOUSE_FILTER_IGNORE
		cell.custom_minimum_size = Vector2(28.0, 28.0)
		cell.clip_contents = true

		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.101961, 0.580392, 0.878431, 1.0)
		style.border_color = Color(0.035294, 0.431373, 0.72549, 1.0)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.corner_radius_top_left = 2
		style.corner_radius_top_right = 2
		style.corner_radius_bottom_left = 2
		style.corner_radius_bottom_right = 2
		cell.add_theme_stylebox_override("panel", style)

		var gloss := ColorRect.new()
		gloss.mouse_filter = Control.MOUSE_FILTER_IGNORE
		gloss.color = Color(0.827451, 0.952941, 1.0, 0.36)
		gloss.position = Vector2(2.0, 2.0)
		gloss.size = Vector2(22.0, 8.0)
		cell.add_child(gloss)

		bar.add_child(cell)
		_health_cells.append(cell)


func _sync_health_ui() -> void:
	for i in range(_health_cells.size()):
		var cell := _health_cells[i]
		cell.modulate = Color(1.0, 1.0, 1.0, 1.0) if i < health else Color(0.45, 0.58, 0.67, 0.28)
