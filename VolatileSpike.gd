extends CharacterBody2D
class_name VolatileSpike

@export var rise_speed: float = 240.0
@export var trace_speed: float = 180.0
@export var return_speed: float = 73.3333333333
@export var trace_duration: float = 20.0
@export var screen_margin: float = 16.0
@export var proximity_min_tiles: float = 2.0
@export var proximity_max_tiles: float = 3.0
@export var proximity_hover_speed: float = 72.0

@onready var contact_area: Area2D = $ContactArea

enum MotionState { IDLE, PROXIMITY, RISING, TRACING, RETURNING }

var state: MotionState = MotionState.IDLE
var origin_position: Vector2
var player: CharacterBody2D
var trace_time_left: float = 0.0
var trace_waypoints: Array[Vector2] = []
var waypoint_index: int = 0
var ceiling_target_y: float = 0.0
var bounds_left_x: float = 0.0
var bounds_right_x: float = 0.0
var bounds_top_y: float = 0.0
var bounds_bottom_y: float = 0.0
var proximity_direction: int = 1


func _ready() -> void:
	origin_position = global_position
	player = get_parent().get_node_or_null("Player") as CharacterBody2D if get_parent() != null else null
	contact_area.body_entered.connect(_on_contact_body_entered)
	_refresh_scene_bounds()


func _physics_process(delta: float) -> void:
	match state:
		MotionState.IDLE:
			if _is_player_in_proximity_band():
				state = MotionState.PROXIMITY
				velocity = Vector2.ZERO
			else:
				velocity = Vector2.ZERO
		MotionState.PROXIMITY:
			if not _is_player_in_proximity_band():
				state = MotionState.IDLE
				velocity = Vector2.ZERO
			else:
				velocity.x = 0.0
				velocity.y = proximity_direction * proximity_hover_speed
				if global_position.y <= bounds_top_y:
					global_position.y = bounds_top_y
					proximity_direction = 1
				elif global_position.y >= bounds_bottom_y:
					global_position.y = bounds_bottom_y
					proximity_direction = -1
		MotionState.RISING:
			velocity = Vector2.UP * rise_speed
			if is_on_ceiling() or global_position.y <= ceiling_target_y:
				global_position.y = minf(global_position.y, ceiling_target_y)
				_begin_trace()
		MotionState.TRACING:
			trace_time_left = maxf(trace_time_left - delta, 0.0)
			_follow_trace_waypoints()
			if trace_time_left <= 0.0:
				state = MotionState.RETURNING
		MotionState.RETURNING:
			velocity = (origin_position - global_position).normalized() * return_speed
			if global_position.distance_to(origin_position) <= 4.0:
				global_position = origin_position
				velocity = Vector2.ZERO
				state = MotionState.IDLE

	move_and_slide()


func _follow_trace_waypoints() -> void:
	if trace_waypoints.is_empty():
		_begin_trace()
		return

	var target := trace_waypoints[waypoint_index]
	var offset := target - global_position
	if offset.length() <= 8.0:
		waypoint_index = posmod(waypoint_index + 1, trace_waypoints.size())
		target = trace_waypoints[waypoint_index]
		offset = target - global_position

	velocity = offset.normalized() * trace_speed


func _begin_trace() -> void:
	_refresh_scene_bounds()
	trace_time_left = trace_duration
	waypoint_index = 0
	trace_waypoints = _build_trace_waypoints()
	state = MotionState.TRACING
	velocity = Vector2.ZERO


func _build_trace_waypoints() -> Array[Vector2]:
	var points: Array[Vector2] = []
	points.append(Vector2(bounds_right_x, bounds_top_y))
	points.append(Vector2(bounds_right_x, bounds_bottom_y))
	points.append(Vector2(bounds_left_x, bounds_bottom_y))
	points.append(Vector2(bounds_left_x, bounds_top_y))
	return points


func _refresh_scene_bounds() -> void:
	var parent_root := get_parent()
	if parent_root == null:
		return

	var floor_rect := _get_node_rect(parent_root.get_node_or_null("Floor"))
	var ceiling_rect := _get_node_rect(parent_root.get_node_or_null("Ceiling"))
	var left_rect := _get_node_rect(parent_root.get_node_or_null("LeftBoundary"))
	var right_rect := _get_node_rect(parent_root.get_node_or_null("RightBoundary"))

	bounds_left_x = left_rect.end.x + screen_margin if left_rect.size != Vector2.ZERO else screen_margin
	bounds_right_x = right_rect.position.x - screen_margin if right_rect.size != Vector2.ZERO else 1280.0 - screen_margin
	bounds_top_y = ceiling_rect.end.y + screen_margin if ceiling_rect.size != Vector2.ZERO else screen_margin
	bounds_bottom_y = floor_rect.position.y - screen_margin if floor_rect.size != Vector2.ZERO else 720.0 - screen_margin
	ceiling_target_y = bounds_top_y + _collision_half_height() + 4.0


func _is_player_in_proximity_band() -> bool:
	if player == null:
		return false

	var distance := player.global_position.distance_to(global_position)
	var min_distance := proximity_min_tiles * 64.0
	var max_distance := proximity_max_tiles * 64.0
	return distance >= min_distance and distance <= max_distance


func _collision_half_height() -> float:
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null or collision_shape.shape == null:
		return 16.0
	var rect_shape := collision_shape.shape as RectangleShape2D
	if rect_shape == null:
		return 16.0
	return rect_shape.size.y * 0.5 * absf(collision_shape.global_scale.y)


func _get_node_rect(node: Node) -> Rect2:
	if node == null:
		return Rect2()

	var collision := node.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null or collision.shape == null:
		return Rect2()

	if collision.shape is RectangleShape2D:
		var rect_shape := collision.shape as RectangleShape2D
		var size := rect_shape.size * Vector2(absf(collision.global_scale.x), absf(collision.global_scale.y))
		return Rect2(collision.global_position - (size * 0.5), size)

	return Rect2()


func _on_contact_body_entered(body: Node2D) -> void:
	if body.has_method("apply_turret_contact_damage"):
		body.call("apply_turret_contact_damage", global_position)
	if body.has_method("apply_turret_knockback"):
		body.call("apply_turret_knockback", global_position)


func apply_player_projectile_hit(_damage: int, _source_position: Vector2, _projectile_velocity: Vector2) -> void:
	origin_position = global_position if state == MotionState.IDLE or state == MotionState.PROXIMITY else origin_position
	trace_time_left = trace_duration
	if state == MotionState.IDLE or state == MotionState.PROXIMITY:
		_refresh_scene_bounds()
		state = MotionState.RISING
		velocity = Vector2.ZERO
