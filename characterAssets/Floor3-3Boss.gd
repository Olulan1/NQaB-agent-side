extends CharacterBody2D
class_name Floor3_3Boss

const TILE_SIZE: float = 64.0
const DISPLAY_HEALTH_MAX: int = 80
const JUMP_SHOT_Y_OFFSET: float = -16.0
const CROUCH_SHOT_Y_OFFSET: float = 8.0
const BOSS_HEALTH_COLOR: Color = Color(0.160784, 0.407843, 0.760784, 1.0)
const HEALTH_BAR_FILL_COLOR: Color = Color(0.160784, 0.407843, 0.760784, 1.0)
const HEALTH_BAR_BACKGROUND_COLOR: Color = Color(0.070588, 0.117647, 0.2, 1.0)
const HEALTH_BAR_MIN_VISIBLE_VALUE: float = 4.0

@export var projectile_scene: PackedScene = preload("res://Projectile.tscn")
@export var fire_interval: float = 1.9
@export var charge_interval: float = 7.0
@export var charge_duration: float = 0.35
@export var charge_distance_tiles: float = 4.0
@export var charge_reverse_chance: float = 0.35
@export var walk_speed_tiles: float = 0.5
@export var max_health: int = 75
@export var projectile_damage: int = 1
@export var projectile_speed: float = 640.0
@export var health_sections: int = 5
@export var player_path: NodePath = NodePath("../Player")

@onready var visual_root: Node2D = $VisualRoot
@onready var muzzle: Marker2D = $VisualRoot/Muzzle
@onready var fire_timer: Timer = $FireTimer
@onready var charge_timer: Timer = $ChargeTimer
@onready var contact_area: Area2D = $ContactArea
@onready var health_bar: ProgressBar = $BossHUD/HealthBar
@onready var boss_health_value: Label = $BossHUD/BossHealthValue

var health: int
var facing: int = -1
var player: CharacterBody2D
var charge_speed_px: float
var walk_speed_px: float
var knockback_speed_px: float = 12.0
var shotgun_knockback_speed_px: float = 48.0
var stun_time_left: float = 0.0
var pending_charge: bool = false
var charge_time_left: float = 0.0
var charge_direction: int = -1
var knockback_time_left: float = 0.0
var knockback_direction: int = 0
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	health = max_health
	player = get_node_or_null(player_path) as CharacterBody2D
	charge_speed_px = (charge_distance_tiles * TILE_SIZE) / charge_duration
	walk_speed_px = walk_speed_tiles * TILE_SIZE
	visual_root.scale.x = facing

	fire_timer.wait_time = fire_interval
	fire_timer.timeout.connect(_fire)
	fire_timer.start()

	charge_timer.wait_time = charge_interval
	charge_timer.timeout.connect(_on_charge_timer_timeout)
	charge_timer.start()

	contact_area.body_entered.connect(_on_contact_body_entered)
	_configure_health_bar()
	_sync_health_bar()
	_sync_boss_health_value()
	rng.randomize()


func _physics_process(delta: float) -> void:
	if stun_time_left > 0.0:
		stun_time_left = maxf(stun_time_left - delta, 0.0)
		velocity.x = 0.0
	elif knockback_time_left > 0.0:
		knockback_time_left = maxf(knockback_time_left - delta, 0.0)
		velocity.x = knockback_direction * knockback_speed_px
	elif charge_time_left > 0.0:
		charge_time_left = maxf(charge_time_left - delta, 0.0)
		velocity.x = charge_direction * charge_speed_px
	else:
		var walk_direction := facing
		if is_instance_valid(player):
			walk_direction = -1 if player.global_position.x < global_position.x else 1
		facing = walk_direction
		visual_root.scale.x = facing
		velocity.x = walk_direction * walk_speed_px

	if not is_on_floor():
		velocity.y += float(ProjectSettings.get_setting("physics/2d/default_gravity")) * delta
	else:
		velocity.y = 0.0

	move_and_slide()

	if is_on_wall():
		if charge_time_left > 0.0:
			charge_time_left = 0.0
			velocity.x = 0.0
		elif knockback_time_left <= 0.0 and stun_time_left <= 0.0:
			facing *= -1
			visual_root.scale.x = facing
			velocity.x = facing * walk_speed_px

	if pending_charge and charge_time_left <= 0.0 and knockback_time_left <= 0.0 and stun_time_left <= 0.0:
		pending_charge = false
		_begin_charge()


func _on_charge_timer_timeout() -> void:
	if stun_time_left > 0.0 or knockback_time_left > 0.0 or charge_time_left > 0.0:
		pending_charge = true
		return
	_begin_charge()


func _begin_charge() -> void:
	if charge_time_left > 0.0:
		return

	var desired_direction := -1
	if is_instance_valid(player):
		desired_direction = -1 if player.global_position.x < global_position.x else 1
	if rng.randf() < charge_reverse_chance:
		desired_direction *= -1

	charge_direction = desired_direction
	facing = desired_direction
	visual_root.scale.x = facing
	charge_time_left = charge_duration
	knockback_time_left = 0.0
	knockback_direction = 0


func _fire() -> void:
	var direction := facing
	if is_instance_valid(player):
		direction = -1 if player.global_position.x < global_position.x else 1

	var spawn_y_offset := JUMP_SHOT_Y_OFFSET if rng.randi_range(0, 1) == 0 else CROUCH_SHOT_Y_OFFSET
	var spawn_position := muzzle.global_position + Vector2(0.0, spawn_y_offset)

	var projectile := projectile_scene.instantiate() as Area2D
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = spawn_position
	_configure_boss_projectile(projectile)
	projectile.set("damage", projectile_damage)
	projectile.set("source_is_player", false)
	projectile.set("free_on_hit", true)
	projectile.modulate = Color(0.964706, 0.176471, 0.176471, 0.96)
	if projectile.has_method("set_direction"):
		projectile.call("set_direction", direction)


func _configure_boss_projectile(projectile: Area2D) -> void:
	projectile.collision_mask = 0
	projectile.set_collision_mask_value(1, true)


func _configure_health_bar() -> void:
	if health_bar == null:
		return
	health_bar.max_value = float(DISPLAY_HEALTH_MAX)
	health_bar.min_value = 0.0
	health_bar.step = 1.0
	health_bar.value = _get_display_health_bar_value()
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = HEALTH_BAR_FILL_COLOR
	fill_style.border_width_left = 0
	fill_style.border_width_top = 0
	fill_style.border_width_right = 0
	fill_style.border_width_bottom = 0
	health_bar.add_theme_stylebox_override("fill", fill_style)

	var background_style := StyleBoxFlat.new()
	background_style.bg_color = HEALTH_BAR_BACKGROUND_COLOR
	background_style.border_width_left = 0
	background_style.border_width_top = 0
	background_style.border_width_right = 0
	background_style.border_width_bottom = 0
	health_bar.add_theme_stylebox_override("background", background_style)


func _sync_health_bar() -> void:
	if health_bar != null:
		health_bar.value = _get_display_health_bar_value()
	_sync_boss_health_value()


func _sync_boss_health_value() -> void:
	if boss_health_value != null:
		boss_health_value.text = "%d" % _get_display_health()
		boss_health_value.add_theme_color_override("font_color", BOSS_HEALTH_COLOR)


func _get_display_health() -> int:
	return clampi(roundi(float(health) * float(DISPLAY_HEALTH_MAX) / float(max_health)), 0, DISPLAY_HEALTH_MAX)


func _get_display_health_bar_value() -> float:
	var display_health := _get_display_health()
	if display_health <= 0:
		return 0.0
	return maxf(HEALTH_BAR_MIN_VISIBLE_VALUE, float(display_health))


func _on_contact_body_entered(body: Node2D) -> void:
	if body.has_method("apply_turret_contact_damage"):
		body.call("apply_turret_contact_damage", global_position)
	if body.has_method("apply_turret_knockback"):
		body.call("apply_turret_knockback", global_position)


func apply_player_projectile_hit(damage: int, source_position: Vector2, _projectile_velocity: Vector2, weapon_kind: int = 0) -> void:
	health = maxi(health - maxi(1, damage), 0)
	_sync_health_bar()
	_apply_weapon_reaction(source_position, weapon_kind)
	if health <= 0:
		queue_free()


func _apply_weapon_reaction(source_position: Vector2, weapon_kind: int) -> void:
	charge_time_left = 0.0
	pending_charge = false
	match weapon_kind:
		2:
			_start_knockback(source_position, shotgun_knockback_speed_px, 0.18)
		3:
			stun_time_left = 2.0
			knockback_time_left = 0.0
			velocity = Vector2.ZERO
		_:
			_start_knockback(source_position, knockback_speed_px, 0.14)


func _start_knockback(source_position: Vector2, speed_px: float, duration: float) -> void:
	var dx := global_position.x - source_position.x
	knockback_direction = 1 if dx >= 0.0 else -1
	knockback_speed_px = speed_px
	knockback_time_left = duration
