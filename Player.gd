extends CharacterBody2D

const WEAPON_ICON_TEXTURES: Array[Texture2D] = [
	preload("res://dev-thoughts/imgs/1.png"),
	preload("res://dev-thoughts/imgs/2.png"),
	preload("res://dev-thoughts/imgs/3.png"),
	preload("res://dev-thoughts/imgs/4.png"),
]

const AMMO_ICON_TEXTURE: Texture2D = preload("res://dev-thoughts/imgs/ammo.png")
const WEAPON_NAMES: PackedStringArray = ["Default", "Burst", "Shotgun", "Laser"]
const WEAPON_AMMO_COUNTS: PackedInt32Array = [6, 4, 2, 1]

const INPUT_ACTIONS := {
	"move_left": [KEY_A, KEY_LEFT],
	"move_right": [KEY_D, KEY_RIGHT],
	"jump": [KEY_SPACE],
	"jump_weak": [KEY_W, KEY_UP],
	"crouch": [KEY_S, KEY_DOWN],
	"fire": [KEY_E],
	"sprint": [KEY_SHIFT],
	"switch_weapon": [KEY_Q],
}

const STANDING_COLLIDER_SIZE := Vector2(20.0, 40.0)
const CROUCH_COLLIDER_SIZE := Vector2(20.0, 28.0)
const STANDING_HEAD_POSITION := Vector2(0.0, -11.0)
const CROUCH_HEAD_POSITION := Vector2(0.0, -8.0)
const STANDING_BODY_POSITION := Vector2(0.0, 9.0)
const CROUCH_BODY_POSITION := Vector2(0.0, 12.0)
const STANDING_BODY_SCALE := Vector2(1.0, 1.0)
const CROUCH_BODY_SCALE := Vector2(1.0, 0.72)
const STANDING_WEAPON_ICON_POSITION := Vector2(14.0, -6.0)
const CROUCH_WEAPON_ICON_POSITION := Vector2(14.0, 0.0)
const HELD_WEAPON_DEFAULT_ICON_SCALE := Vector2(0.08, 0.08)
const HELD_WEAPON_OTHER_ICON_SCALE := Vector2(0.136, 0.136)

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
@export var fire_cooldown: float = 0.18
@export var burst_fire_cooldown: float = 1.5
@export var burst_shot_spacing: float = 0.1
@export var shotgun_fire_cooldown: float = 1.2
@export var shotgun_projectile_speed: float = 300.0
@export var shotgun_projectile_range: float = 320.0
@export var shotgun_spread_gradient: float = 0.11
@export var laser_fire_cooldown: float = 2.0
@export var laser_beam_length: float = 224.0
@export var laser_beam_duration: float = 0.7
@export var projectile_scene: PackedScene = preload("res://Projectile.tscn")
@export var projectile_spawn_offset: Vector2 = Vector2(18.0, -8.0)
@export var crouched_projectile_spawn_offset: Vector2 = Vector2(18.0, 2.0)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var head_visual: Polygon2D = $VisualRoot/Head
@onready var body_visual: Polygon2D = $VisualRoot/Body
@onready var weapon_icon: Sprite2D = $VisualRoot/WeaponIcon
@onready var muzzle: Marker2D = $Muzzle

var health: int = 5
var invulnerability_time_left: float = 0.0
var facing: int = 1
var fire_timer: float = 0.0
var current_weapon_index: int = 0
var burst_shots_remaining: int = 0
var burst_shot_timer: float = 0.0
var crouching: bool = false
var knockback_time_left: float = 0.0
var _health_cells: Array[Panel] = []
var _ammo_icons: Array[TextureRect] = []
var _weapon_boxes: Array[Panel] = []


func _ready() -> void:
	_ensure_input_actions()
	SceneTransition.player_max_health = max_health
	if SceneTransition.player_health <= 0:
		SceneTransition.reset_player_health()
	health = clampi(SceneTransition.player_health, 0, max_health)
	SceneTransition.set_player_health(health)
	_build_health_ui()
	_sync_health_ui()
	_sync_weapon_icon_scale()
	_sync_weapon_ui()
	_sync_ammo_ui()
	_update_crouch_state()
	_update_muzzle_position()


func _physics_process(delta: float) -> void:
	if fire_timer > 0.0:
		fire_timer = maxf(fire_timer - delta, 0.0)
	if invulnerability_time_left > 0.0:
		invulnerability_time_left = maxf(invulnerability_time_left - delta, 0.0)
	if knockback_time_left > 0.0:
		knockback_time_left = maxf(knockback_time_left - delta, 0.0)

	if burst_shots_remaining > 0:
		burst_shot_timer -= delta
		while burst_shots_remaining > 0 and burst_shot_timer <= 0.0:
			_spawn_projectile_for_current_weapon()
			burst_shots_remaining -= 1
			if burst_shots_remaining > 0:
				burst_shot_timer += burst_shot_spacing

	var left_held := Input.is_action_pressed("move_left")
	var right_held := Input.is_action_pressed("move_right")
	var horizontal := 0.0
	if knockback_time_left <= 0.0 and left_held != right_held:
		horizontal = -1.0 if left_held else 1.0
		facing = -1 if left_held else 1

	crouching = Input.is_action_pressed("crouch")
	_update_crouch_state()
	_update_muzzle_position()

	if not is_on_floor():
		var gravity_multiplier := crouch_fall_gravity_multiplier if crouching else 1.0
		velocity.y += fall_gravity * gravity_multiplier * delta

	var jump_pressed := Input.is_action_just_pressed("jump")
	var weak_jump_pressed := Input.is_action_just_pressed("jump_weak")
	if is_on_floor():
		if jump_pressed:
			velocity.y = jump_velocity
		elif weak_jump_pressed:
			velocity.y = jump_velocity * 0.5

	if knockback_time_left <= 0.0:
		var move_speed := crouch_speed if crouching else speed
		if Input.is_action_pressed("sprint"):
			move_speed *= sprint_multiplier
		velocity.x = horizontal * move_speed

	if Input.is_action_just_pressed("switch_weapon"):
		current_weapon_index = posmod(current_weapon_index + 1, WEAPON_ICON_TEXTURES.size())
		_sync_weapon_ui()
		_sync_ammo_ui()

	if Input.is_action_just_pressed("fire"):
		_try_fire_current_weapon()

	move_and_slide()


func _ensure_input_actions() -> void:
	for action_name in INPUT_ACTIONS.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		if InputMap.action_get_events(action_name).size() > 0:
			continue
		for keycode in INPUT_ACTIONS[action_name]:
			var event := InputEventKey.new()
			event.keycode = keycode
			event.physical_keycode = keycode
			event.pressed = false
			event.echo = false
			InputMap.action_add_event(action_name, event)


func _update_crouch_state() -> void:
	var shape := collision_shape.shape as RectangleShape2D
	if shape == null:
		return

	if crouching:
		shape.size = CROUCH_COLLIDER_SIZE
		head_visual.position = CROUCH_HEAD_POSITION
		body_visual.position = CROUCH_BODY_POSITION
		body_visual.scale = CROUCH_BODY_SCALE
		weapon_icon.position = CROUCH_WEAPON_ICON_POSITION
		collision_shape.position = Vector2(0.0, 6.0)
	else:
		shape.size = STANDING_COLLIDER_SIZE
		head_visual.position = STANDING_HEAD_POSITION
		body_visual.position = STANDING_BODY_POSITION
		body_visual.scale = STANDING_BODY_SCALE
		weapon_icon.position = STANDING_WEAPON_ICON_POSITION
		collision_shape.position = Vector2.ZERO


func _update_muzzle_position() -> void:
	var offset := crouched_projectile_spawn_offset if crouching else projectile_spawn_offset
	muzzle.position = Vector2(offset.x * facing, offset.y)
	weapon_icon.flip_h = facing < 0
	weapon_icon.position.x = absf(weapon_icon.position.x) * facing


func _sync_weapon_icon_scale() -> void:
	if weapon_icon != null:
		weapon_icon.scale = HELD_WEAPON_DEFAULT_ICON_SCALE if current_weapon_index == 0 else HELD_WEAPON_OTHER_ICON_SCALE


func _try_fire_current_weapon() -> void:
	if fire_timer > 0.0:
		return

	match current_weapon_index:
		0:
			fire_timer = fire_cooldown
			_spawn_default_projectile()
		1:
			fire_timer = burst_fire_cooldown
			burst_shots_remaining = 2
			burst_shot_timer = burst_shot_spacing
			_spawn_default_projectile()
		2:
			fire_timer = shotgun_fire_cooldown
			_spawn_shotgun_projectiles()
		3:
			fire_timer = laser_fire_cooldown
			_spawn_laser_beam()
		_:
			fire_timer = fire_cooldown
			_spawn_default_projectile()


func _spawn_projectile_for_current_weapon() -> void:
	if current_weapon_index == 1:
		_spawn_default_projectile()


func _spawn_default_projectile() -> void:
	var projectile := projectile_scene.instantiate() as Area2D
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = muzzle.global_position
	projectile.set("damage", projectile_damage)
	projectile.set("source_is_player", true)
	projectile.set("free_on_hit", true)
	if projectile.has_method("set_direction"):
		projectile.call("set_direction", facing)


func _spawn_shotgun_projectiles() -> void:
	var directions := [
		Vector2(shotgun_projectile_speed * facing, -shotgun_projectile_speed * shotgun_spread_gradient),
		Vector2(shotgun_projectile_speed * facing, 0.0),
		Vector2(shotgun_projectile_speed * facing, shotgun_projectile_speed * shotgun_spread_gradient),
	]
	for velocity in directions:
		var projectile := projectile_scene.instantiate() as Area2D
		get_tree().current_scene.add_child(projectile)
		projectile.global_position = muzzle.global_position
		projectile.scale = Vector2(0.5, 0.5)
		projectile.set("damage", 3)
		projectile.set("source_is_player", true)
		projectile.set("free_on_hit", true)
		projectile.set("max_distance", shotgun_projectile_range)
		projectile.set("damage_profile_durations", PackedFloat32Array([0.7, 0.8, 0.6]))
		projectile.set("damage_profile_values", PackedInt32Array([3, 2, 1]))
		if projectile.has_method("set_velocity"):
			projectile.call("set_velocity", velocity)
		elif projectile.has_method("set_direction"):
			projectile.call("set_direction", facing)


func _spawn_laser_beam() -> void:
	var projectile := projectile_scene.instantiate() as Area2D
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = muzzle.global_position + Vector2((laser_beam_length * 0.5) * facing, 0.0)
	projectile.scale = Vector2((laser_beam_length / 14.0) * facing, 2.0)
	projectile.modulate = Color(1.0, 0.2, 0.2, 0.92)
	projectile.set("damage", 1)
	projectile.set("source_is_player", true)
	projectile.set("free_on_hit", false)
	projectile.set("max_distance", 0.0)
	projectile.set("damage_profile_durations", PackedFloat32Array())
	projectile.set("damage_profile_values", PackedInt32Array())
	projectile.set("lifetime", laser_beam_duration)
	if projectile.has_method("set_velocity"):
		projectile.call("set_velocity", Vector2.ZERO)
	elif projectile.has_method("set_direction"):
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
	if get_node_or_null("HUDLayer") != null:
		return

	var layer := CanvasLayer.new()
	layer.name = "HUDLayer"
	layer.layer = 10
	add_child(layer)

	var root := Control.new()
	root.name = "HUDRoot"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.position = Vector2(24.0, 24.0)
	root.size = Vector2(240.0, 120.0)
	layer.add_child(root)

	var frame := Panel.new()
	frame.name = "HealthFrame"
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.position = Vector2.ZERO
	frame.size = Vector2(176.0, 44.0)
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

	var ammo_frame := Panel.new()
	ammo_frame.name = "AmmoFrame"
	ammo_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ammo_frame.position = Vector2.ZERO
	ammo_frame.size = Vector2(176.0, 28.0)
	ammo_frame.visible = true
	var ammo_frame_style := StyleBoxFlat.new()
	ammo_frame_style.bg_color = Color(0.168627, 0.180392, 0.211765, 0.9)
	ammo_frame_style.border_color = Color(0.078431, 0.086275, 0.105882, 1.0)
	ammo_frame_style.border_width_left = 2
	ammo_frame_style.border_width_top = 2
	ammo_frame_style.border_width_right = 2
	ammo_frame_style.border_width_bottom = 2
	ammo_frame_style.corner_radius_top_left = 3
	ammo_frame_style.corner_radius_top_right = 3
	ammo_frame_style.corner_radius_bottom_left = 3
	ammo_frame_style.corner_radius_bottom_right = 3
	ammo_frame.add_theme_stylebox_override("panel", ammo_frame_style)
	root.add_child(ammo_frame)
	ammo_frame.position = Vector2(0.0, 52.0)

	var ammo_row := HBoxContainer.new()
	ammo_row.name = "AmmoRow"
	ammo_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ammo_row.position = Vector2(8.0, 4.0)
	ammo_row.add_theme_constant_override("separation", 6)
	ammo_frame.add_child(ammo_row)

	_ammo_icons.clear()
	for i in range(6):
		var icon := TextureRect.new()
		icon.name = "Ammo%02d" % (i + 1)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.texture = AMMO_ICON_TEXTURE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.custom_minimum_size = Vector2(20.0, 20.0)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		ammo_row.add_child(icon)
		_ammo_icons.append(icon)

	var weapon_frame := Panel.new()
	weapon_frame.name = "WeaponFrame"
	weapon_frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	weapon_frame.position = Vector2(0.0, 88.0)
	weapon_frame.size = Vector2(176.0, 38.0)
	var weapon_frame_style := StyleBoxFlat.new()
	weapon_frame_style.bg_color = Color(0.117647, 0.121569, 0.141176, 0.95)
	weapon_frame_style.border_color = Color(0.011765, 0.011765, 0.011765, 1.0)
	weapon_frame_style.border_width_left = 2
	weapon_frame_style.border_width_top = 2
	weapon_frame_style.border_width_right = 2
	weapon_frame_style.border_width_bottom = 2
	weapon_frame_style.corner_radius_top_left = 2
	weapon_frame_style.corner_radius_top_right = 2
	weapon_frame_style.corner_radius_bottom_left = 2
	weapon_frame_style.corner_radius_bottom_right = 2
	weapon_frame.add_theme_stylebox_override("panel", weapon_frame_style)
	root.add_child(weapon_frame)

	var weapon_row := HBoxContainer.new()
	weapon_row.name = "WeaponRow"
	weapon_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	weapon_row.position = Vector2(6.0, 4.0)
	weapon_row.add_theme_constant_override("separation", 6)
	weapon_frame.add_child(weapon_row)

	_weapon_boxes.clear()
	for i in range(WEAPON_ICON_TEXTURES.size()):
		var box := Panel.new()
		box.name = "WeaponBox%02d" % (i + 1)
		box.mouse_filter = Control.MOUSE_FILTER_IGNORE
		box.custom_minimum_size = Vector2(30.0, 30.0)
		box.clip_contents = true
		weapon_row.add_child(box)

		var box_style := StyleBoxFlat.new()
		box_style.bg_color = Color(0.0, 0.0, 0.0, 1.0)
		box_style.border_color = Color(0.188235, 0.188235, 0.188235, 1.0)
		box_style.border_width_left = 2
		box_style.border_width_top = 2
		box_style.border_width_right = 2
		box_style.border_width_bottom = 2
		box_style.corner_radius_top_left = 2
		box_style.corner_radius_top_right = 2
		box_style.corner_radius_bottom_left = 2
		box_style.corner_radius_bottom_right = 2
		box.add_theme_stylebox_override("panel", box_style)

		var icon := TextureRect.new()
		icon.name = "WeaponIcon"
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.texture = WEAPON_ICON_TEXTURES[i]
		icon.tooltip_text = WEAPON_NAMES[i]
		icon.custom_minimum_size = Vector2(24.0, 24.0)
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.position = Vector2(3.0, 3.0)
		box.add_child(icon)

		_weapon_boxes.append(box)


func _sync_health_ui() -> void:
	for i in range(_health_cells.size()):
		var cell := _health_cells[i]
		cell.modulate = Color(1.0, 1.0, 1.0, 1.0) if i < health else Color(0.45, 0.58, 0.67, 0.28)


func _sync_weapon_ui() -> void:
	if weapon_icon != null:
		_sync_weapon_icon_scale()
		weapon_icon.texture = WEAPON_ICON_TEXTURES[current_weapon_index]
		weapon_icon.centered = true
		weapon_icon.flip_h = facing < 0
		weapon_icon.position = Vector2(
			absf(STANDING_WEAPON_ICON_POSITION.x) * facing,
			CROUCH_WEAPON_ICON_POSITION.y if crouching else STANDING_WEAPON_ICON_POSITION.y
		)
	for i in range(_weapon_boxes.size()):
		var box := _weapon_boxes[i]
		var style := box.get_theme_stylebox("panel") as StyleBoxFlat
		if style == null:
			continue
		if i == current_weapon_index:
			style.border_color = Color(0.870588, 0.960784, 1.0, 1.0)
			style.bg_color = Color(0.070588, 0.133333, 0.196078, 1.0)
		else:
			style.border_color = Color(0.188235, 0.188235, 0.188235, 1.0)
			style.bg_color = Color(0.0, 0.0, 0.0, 1.0)


func _sync_ammo_ui() -> void:
	var ammo_count := WEAPON_AMMO_COUNTS[current_weapon_index]
	for i in range(_ammo_icons.size()):
		var icon := _ammo_icons[i]
		icon.visible = i < ammo_count
		icon.modulate = Color(1.0, 1.0, 1.0, 1.0) if i < ammo_count else Color(1.0, 1.0, 1.0, 0.0)
