extends Area2D

@export_file("*.tscn") var target_scene_path: String = ""
@export var target_spawn_name: String = ""
@export var caption_text: String = "EXIT ELEVATOR"

@onready var caption: Label = $Caption

var _transitioning: bool = false


func _ready() -> void:
	if caption != null:
		caption.text = caption_text
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if _transitioning or target_scene_path.is_empty():
		return
	if body.name != "Player":
		return

	_transitioning = true
	SceneTransition.set_pending_spawn_name(target_spawn_name)
	get_tree().call_deferred("change_scene_to_file", target_scene_path)
