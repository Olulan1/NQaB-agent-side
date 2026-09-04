extends Area2D
class_name TeleportPortal

@export var linked_portal_path: NodePath = NodePath("")
@export var player_path: NodePath = NodePath("../Player")
@export_file("*.png") var open_texture_path: String = "res://dev-thoughts/imgs/portal.png"
@export_file("*.png") var closed_texture_path: String = "res://dev-thoughts/imgs/portalClosed.png"
@export var caption_text: String = "Press X to teleport!"
@export var cooldown_seconds: float = 8.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var caption: Label = $Caption
@onready var exit_point: Marker2D = $ExitPoint

var player: CharacterBody2D
var open_texture: Texture2D
var closed_texture: Texture2D
var _player_in_contact: bool = false
var _x_was_down: bool = false
var _cooldown_time_left: float = 0.0


func _ready() -> void:
	player = get_node_or_null(player_path) as CharacterBody2D
	open_texture = _load_texture(open_texture_path)
	closed_texture = _load_texture(closed_texture_path)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_apply_open_state()


func _physics_process(delta: float) -> void:
	if _cooldown_time_left > 0.0:
		_cooldown_time_left = maxf(_cooldown_time_left - delta, 0.0)
		if _cooldown_time_left <= 0.0:
			_apply_open_state()
		return

	if not _player_in_contact:
		_x_was_down = false
		return

	var x_down := Input.is_key_pressed(KEY_X)
	if x_down and not _x_was_down:
		_try_teleport()
	_x_was_down = x_down


func _try_teleport() -> void:
	if _cooldown_time_left > 0.0:
		return

	var partner := get_node_or_null(linked_portal_path) as TeleportPortal
	if partner == null:
		return

	var target_point := partner.exit_point.global_position if partner.exit_point != null else partner.global_position
	if player != null:
		player.velocity = Vector2.ZERO
		player.global_position = target_point

	_begin_cooldown()
	partner._begin_cooldown()


func _begin_cooldown() -> void:
	_cooldown_time_left = cooldown_seconds
	if sprite != null and closed_texture != null:
		sprite.texture = closed_texture
	if caption != null:
		caption.visible = false


func _apply_open_state() -> void:
	if sprite != null and open_texture != null:
		sprite.texture = open_texture
	if caption != null:
		caption.visible = true
		caption.text = caption_text


func _load_texture(texture_path: String) -> Texture2D:
	if texture_path.is_empty():
		return null

	var image := Image.new()
	var error := image.load(texture_path)
	if error != OK:
		push_error("Failed to load portal texture: %s" % texture_path)
		return null
	return ImageTexture.create_from_image(image)


func _on_body_entered(body: Node) -> void:
	if body.name != "Player":
		return
	_player_in_contact = true
	player = body as CharacterBody2D


func _on_body_exited(body: Node) -> void:
	if body.name != "Player":
		return
	_player_in_contact = false
	_x_was_down = false
