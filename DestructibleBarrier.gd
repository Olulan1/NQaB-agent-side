extends StaticBody2D
class_name DestructibleBarrier

@export var max_health: int = 1
@export var body_color: Color = Color(0.5, 0.5, 0.5, 1.0)
@export var caption_text: String = ""
@export var caption_color: Color = Color(0.968627, 0.968627, 0.968627, 1.0)
@export var caption_font_size: int = 16
@export var caption_width: float = 420.0
@export var caption_height: float = 54.0
@export var caption_gap: float = 12.0
@export var show_dots: bool = false
@export var dot_color: Color = Color(0.85098, 0.172549, 0.192157, 1.0)
@export var dot_size: Vector2 = Vector2(8.0, 8.0)
@export var dot_count: int = 4
@export var dependency_path: NodePath = NodePath("")

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var health: int


func _ready() -> void:
	health = max_health
	_build_visuals()
	_hook_dependency()


func _build_visuals() -> void:
	var rect_shape := collision_shape.shape as RectangleShape2D
	var body_size := Vector2(48.0, 128.0)
	if rect_shape != null:
		body_size = rect_shape.size

	var body_visual := _ensure_polygon("BodyVisual")
	body_visual.polygon = _rectangle_polygon(body_size)
	body_visual.color = body_color
	body_visual.z_index = 0

	var caption := _ensure_label("Caption")
	if caption_text.is_empty():
		caption.visible = false
	else:
		caption.visible = true
		caption.text = caption_text
		caption.position = Vector2(-caption_width * 0.5, -body_size.y * 0.5 - caption_height - caption_gap)
		caption.size = Vector2(caption_width, caption_height)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		caption.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		caption.add_theme_color_override("font_color", caption_color)
		caption.add_theme_font_size_override("font_size", caption_font_size)
		caption.z_index = 1

	var dot_nodes := _ensure_dot_nodes(maxi(dot_count, 0))
	var step := body_size.y / float(dot_nodes.size() + 1) if dot_nodes.size() > 0 else 0.0
	for i in range(dot_nodes.size()):
		var dot := dot_nodes[i]
		dot.visible = show_dots
		if not show_dots:
			continue
		dot.color = dot_color
		dot.polygon = _rectangle_polygon(dot_size)
		dot.position = Vector2(0.0, -body_size.y * 0.5 + step * float(i + 1))
		dot.z_index = 1


func _hook_dependency() -> void:
	if dependency_path == NodePath(""):
		return
	var dependency := get_node_or_null(dependency_path)
	if dependency == null:
		return
	dependency.tree_exited.connect(_on_dependency_tree_exited)


func _on_dependency_tree_exited() -> void:
	queue_free()


func apply_player_projectile_hit(damage: int, _source_position: Vector2, _projectile_velocity: Vector2) -> void:
	health = maxi(health - maxi(1, damage), 0)
	if health <= 0:
		queue_free()


func _ensure_polygon(node_name: String) -> Polygon2D:
	var polygon := get_node_or_null(node_name) as Polygon2D
	if polygon == null:
		polygon = Polygon2D.new()
		polygon.name = node_name
		add_child(polygon)
	return polygon


func _ensure_label(node_name: String) -> Label:
	var label := get_node_or_null(node_name) as Label
	if label == null:
		label = Label.new()
		label.name = node_name
		add_child(label)
	return label


func _ensure_dot_nodes(count: int) -> Array[Polygon2D]:
	var nodes: Array[Polygon2D] = []
	for i in range(count):
		var dot_name := "Dot%d" % (i + 1)
		var dot := get_node_or_null(dot_name) as Polygon2D
		if dot == null:
			dot = Polygon2D.new()
			dot.name = dot_name
			add_child(dot)
		nodes.append(dot)
	return nodes


func _rectangle_polygon(size: Vector2) -> PackedVector2Array:
	var half_width := size.x * 0.5
	var half_height := size.y * 0.5
	return PackedVector2Array([
		Vector2(-half_width, -half_height),
		Vector2(half_width, -half_height),
		Vector2(half_width, half_height),
		Vector2(-half_width, half_height),
	])
