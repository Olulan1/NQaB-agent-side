extends CharacterBody2D
class_name Dasher

const TILE_SIZE: float = 64.0
const DASH_WARNING_DURATION_RATIO: float = 0.5
const DASH_START_GAP: float = 0.01

@export var dash_interval: float = 2.0
@export var dash_distance_tiles: float = 4.0
@export var dash_duration: float = 0.35
@export var max_health: int = 8
@export var player_path: NodePath = NodePath("../Player")

@onready var visual_root: Node2D = $VisualRoot
@onready var dash_timer: Timer = $DashTimer
@onready var dash_warning_timer: Timer = $DashWarningTimer
@onready var dash_start_timer: Timer = $DashStartTimer
@onready var dash_warning: Label = $DashWarning
@onready var contact_area: Area2D = $ContactArea

var health: int = 8
var player: CharacterBody2D
var dash_time_left: float = 0.0
var dash_direction: int = -1
var dash_speed_px: float = 0.0
var dash_warning_duration: float = 0.0
var gravity_px: float = 0.0
var bounds_left_x: float = -INF
var bounds_right_x: float = INF
var facing: int = -1


func _ready() -> void:
	health = max_health
	player = get_node_or_null(player_path) as CharacterBody2D
	randomize()
	dash_speed_px = (dash_distance_tiles * TILE_SIZE) / dash_duration
	gravity_px = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
	dash_warning_duration = maxf(dash_duration * DASH_WARNING_DURATION_RATIO, 0.01)
	dash_timer.wait_time = maxf(dash_interval - dash_warning_duration - DASH_START_GAP, 0.01)
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_on_dash_timer_timeout)
	dash_warning_timer.wait_time = dash_warning_duration
	dash_warning_timer.one_shot = true
	dash_warning_timer.timeout.connect(_on_dash_warning_timeout)
	dash_start_timer.wait_time = DASH_START_GAP
	dash_start_timer.one_shot = true
	dash_start_timer.timeout.connect(_on_dash_start_timeout)
	contact_area.body_entered.connect(_on_contact_body_entered)
	_refresh_bounds()
	visual_root.scale.x = facing
	dash_timer.start()


func _physics_process(delta: float) -> void:
	_refresh_bounds()
	if not is_on_floor():
		velocity.y += gravity_px * delta
	else:
		velocity.y = 0.0

	if dash_time_left > 0.0:
		dash_time_left = maxf(dash_time_left - delta, 0.0)
		velocity.x = dash_direction * dash_speed_px
	else:
		velocity.x = 0.0

	move_and_slide()

	if global_position.x <= bounds_left_x:
		global_position.x = bounds_left_x
		dash_direction = 1
	elif global_position.x >= bounds_right_x:
		global_position.x = bounds_right_x
		dash_direction = -1

	if is_on_wall():
		dash_direction *= -1

	if dash_direction != 0:
		facing = dash_direction
		visual_root.scale.x = facing


func _on_dash_timer_timeout() -> void:
	if dash_time_left > 0.0:
		return

	dash_warning.visible = true
	dash_warning_timer.start()


func _on_dash_warning_timeout() -> void:
	dash_warning.visible = false
	dash_start_timer.start()


func _on_dash_start_timeout() -> void:
	if dash_time_left > 0.0:
		return

	dash_direction = -1 if randf() < 0.5 else 1

	var projected_x := global_position.x + (dash_distance_tiles * TILE_SIZE * dash_direction)
	if projected_x < bounds_left_x or projected_x > bounds_right_x:
		dash_direction *= -1

	dash_time_left = dash_duration
	dash_timer.start()


func _refresh_bounds() -> void:
	var parent_root := get_parent()
	if parent_root == null:
		return

	var left_boundary := parent_root.get_node_or_null("LeftBoundary") as Node2D
	var right_boundary := parent_root.get_node_or_null("RightBoundary") as Node2D
	if left_boundary != null:
		bounds_left_x = left_boundary.global_position.x + 24.0
	if right_boundary != null:
		bounds_right_x = right_boundary.global_position.x - 24.0

	var visible_rect := get_viewport().get_visible_rect()
	if visible_rect.size.x > 0.0:
		var visible_left_x := visible_rect.position.x + 16.0
		var visible_right_x := visible_rect.position.x + visible_rect.size.x - 16.0
		bounds_left_x = maxf(bounds_left_x, visible_left_x)
		bounds_right_x = minf(bounds_right_x, visible_right_x)
		if bounds_right_x < bounds_left_x:
			bounds_right_x = bounds_left_x


func _on_contact_body_entered(body: Node2D) -> void:
	if body.has_method("apply_turret_contact_damage"):
		body.call("apply_turret_contact_damage", global_position)
	if body.has_method("apply_turret_knockback"):
		body.call("apply_turret_knockback", global_position)


func apply_player_projectile_hit(damage: int, _source_position: Vector2, _projectile_velocity: Vector2, _weapon_kind: int = 0) -> void:
	health = maxi(health - maxi(1, damage), 0)
	if health <= 0:
		queue_free()
