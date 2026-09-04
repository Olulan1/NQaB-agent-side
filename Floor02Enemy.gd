extends CharacterBody2D
class_name Floor02Enemy

const TILE_SIZE: float = 64.0

@export var projectile_scene: PackedScene = preload("res://Projectile.tscn")
@export var fire_interval: float = 1.9
@export var max_health: int = 5
@export var projectile_damage: int = 1
@export var projectile_speed: float = 640.0
@export var detection_range_tiles: float = 3.0
@export var move_speed_tiles_per_second: float = 0.24
@export var player_path: NodePath = NodePath("../Player")

@onready var visual_root: Node2D = $VisualRoot
@onready var muzzle: Marker2D = $VisualRoot/Muzzle
@onready var fire_timer: Timer = $FireTimer
@onready var detection_area: Area2D = $DetectionArea
@onready var contact_area: Area2D = $ContactArea

var health: int
var facing: int = -1
var player: CharacterBody2D
var player_in_range: bool = false
var move_speed_px: float
var detection_range_px: float
var gravity_px: float


func _ready() -> void:
	health = max_health
	player = get_node_or_null(player_path) as CharacterBody2D
	move_speed_px = move_speed_tiles_per_second * TILE_SIZE
	detection_range_px = detection_range_tiles * TILE_SIZE
	gravity_px = ProjectSettings.get_setting("physics/2d/default_gravity")
	visual_root.scale.x = facing
	fire_timer.wait_time = fire_interval
	fire_timer.timeout.connect(_fire)
	detection_area.body_entered.connect(_on_detection_body_entered)
	detection_area.body_exited.connect(_on_detection_body_exited)
	contact_area.body_entered.connect(_on_contact_body_entered)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity_px * delta
	else:
		velocity.y = 0.0

	if is_instance_valid(player):
		var distance_x := absf(player.global_position.x - global_position.x)
		var distance_y := absf(player.global_position.y - global_position.y)
		player_in_range = distance_x <= detection_range_px and distance_y <= TILE_SIZE
	else:
		player_in_range = false

	if player_in_range and is_instance_valid(player):
		facing = -1 if player.global_position.x < global_position.x else 1
		velocity.x = facing * move_speed_px
		if fire_timer.is_stopped():
			fire_timer.start()
	else:
		velocity.x = facing * move_speed_px
		if not fire_timer.is_stopped():
			fire_timer.stop()

	visual_root.scale.x = facing
	move_and_slide()

	if is_on_wall():
		facing *= -1
		visual_root.scale.x = facing


func _fire() -> void:
	if not player_in_range or not is_instance_valid(player):
		return

	var direction := -1 if player.global_position.x < global_position.x else 1
	var projectile := projectile_scene.instantiate() as Area2D
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = muzzle.global_position
	_configure_enemy_projectile(projectile)
	projectile.set("damage", projectile_damage)
	projectile.set("source_is_player", false)
	projectile.set("free_on_hit", true)
	projectile.modulate = Color(0.231373, 0.835294, 0.262745, 0.95)
	if projectile.has_method("set_direction"):
		projectile.call("set_direction", direction)


func _on_detection_body_entered(body: Node) -> void:
	if body.name == "Player":
		player = body as CharacterBody2D
		player_in_range = true
		if fire_timer.is_stopped():
			fire_timer.start()


func _on_detection_body_exited(body: Node) -> void:
	if body.name == "Player":
		player_in_range = false
		if not fire_timer.is_stopped():
			fire_timer.stop()


func _on_contact_body_entered(body: Node) -> void:
	if body.has_method("apply_turret_contact_damage"):
		body.call("apply_turret_contact_damage", global_position)


func apply_player_projectile_hit(damage: int, _source_position: Vector2, _projectile_velocity: Vector2, _weapon_kind: int = 0) -> void:
	health = maxi(health - maxi(1, damage), 0)
	if health <= 0:
		queue_free()


func _configure_enemy_projectile(projectile: Area2D) -> void:
	projectile.collision_mask = 0
	projectile.set_collision_mask_value(1, true)
