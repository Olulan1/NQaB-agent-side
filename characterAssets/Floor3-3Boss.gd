extends CharacterBody2D
class_name Floor3_3Boss

const TILE_SIZE: float = 64.0

@export var projectile_scene: PackedScene = preload("res://Projectile.tscn")
@export var fire_interval: float = 1.9
@export var charge_interval: float = 7.0
@export var charge_duration: float = 0.35
@export var charge_distance_tiles: float = 4.0
@export var charge_reverse_chance: float = 0.35
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

var health: int
var facing: int = -1
var player: CharacterBody2D
var charge_speed_px: float
var charge_time_left: float = 0.0
var charge_direction: int = -1
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	health = max_health
	player = get_node_or_null(player_path) as CharacterBody2D
	charge_speed_px = (charge_distance_tiles * TILE_SIZE) / charge_duration
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
	rng.randomize()


func _physics_process(delta: float) -> void:
	velocity.y = 0.0

	if charge_time_left > 0.0:
		charge_time_left = maxf(charge_time_left - delta, 0.0)
		velocity.x = charge_direction * charge_speed_px
	else:
		velocity.x = 0.0

	move_and_slide()

	if is_on_wall() and charge_time_left > 0.0:
		charge_time_left = 0.0
		velocity.x = 0.0


func _on_charge_timer_timeout() -> void:
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


func _fire() -> void:
	var direction := facing
	if is_instance_valid(player):
		direction = -1 if player.global_position.x < global_position.x else 1

	var projectile := projectile_scene.instantiate() as Area2D
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = muzzle.global_position
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
	health_bar.max_value = float(max_health)
	health_bar.min_value = 0.0
	health_bar.step = float(max_health) / float(maxi(health_sections, 1))
	health_bar.value = float(health)


func _sync_health_bar() -> void:
	if health_bar != null:
		health_bar.value = float(health)


func _on_contact_body_entered(body: Node2D) -> void:
	if body.has_method("apply_turret_contact_damage"):
		body.call("apply_turret_contact_damage", global_position)
	if body.has_method("apply_turret_knockback"):
		body.call("apply_turret_knockback", global_position)


func apply_player_projectile_hit(damage: int, _source_position: Vector2, _projectile_velocity: Vector2) -> void:
	health = maxi(health - maxi(1, damage), 0)
	_sync_health_bar()
	if health <= 0:
		queue_free()
