extends Node2D


@onready var day_18_part_2: Day18Part2 = preload("res://src/day_18/day_18_part_2.gd").new()


signal iterate

var has_begun := false

var polygon_example: Array[Vector2i] = [
	Vector2i(0, 0),
	Vector2i(7, 0),
	Vector2i(7, 6),
	Vector2i(5, 6),
	Vector2i(5, 7),
	Vector2i(7, 7),
	Vector2i(7, 10),
	Vector2i(1, 10),
	Vector2i(1, 8),
	Vector2i(0, 8),
	Vector2i(0, 5),
	Vector2i(2, 5),
	Vector2i(2, 3),
	Vector2i(0, 3),
]

@warning_ignore("integer_division")
var polygon_complex: Array[Vector2i] = [
	Vector2i(0 / 32, 0 / 32),
	Vector2i(0 / 32, 64 / 32),
	Vector2i(-64 / 32, 64 / 32),
	Vector2i(-64 / 32, 32 / 32),
	Vector2i(-128 / 32, 32 / 32),
	Vector2i(-128 / 32, 64 / 32),
	Vector2i(-192 / 32, 64 / 32),
	Vector2i(-192 / 32, 128 / 32),
	Vector2i(-160 / 32, 128 / 32),
	Vector2i(-160 / 32, 96 / 32),
	Vector2i(-96 / 32, 96 / 32),
	Vector2i(-96 / 32, 160 / 32),
	Vector2i(-160 / 32, 160 / 32),
	Vector2i(-160 / 32, 192 / 32),
	Vector2i(-64 / 32, 192 / 32),
	Vector2i(-64 / 32, 128 / 32),
	Vector2i(0 / 32, 128 / 32),
	Vector2i(0 / 32, 192 / 32),
	Vector2i(128 / 32, 192 / 32),
	Vector2i(128 / 32, 96 / 32),
	Vector2i(96 / 32, 96 / 32),
	Vector2i(96 / 32, 32 / 32),
	Vector2i(64 / 32, 32 / 32),
	Vector2i(64 / 32, 0 / 32),
]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	polygon_complex.reverse()
	day_18_part_2.partition_iterated.connect(redraw)
	redraw(polygon_complex, [])


func iterate_partitioning() -> void:
	if has_begun:
		iterate.emit()
	else:
		day_18_part_2.partition_polygon(polygon_complex, iterate)
		has_begun = true


var rects: Array[Rect2i]

func redraw(polygon_to_draw: Array[Vector2i], p_rects: Array[Rect2i]) -> void:
	self.rects = p_rects

	var polygon_float: PackedVector2Array = PackedVector2Array()

	for vertex: Vector2i in polygon_to_draw:
		polygon_float.append(Vector2(vertex) * 32)

	$Polygon2D.polygon = polygon_float

	queue_redraw()


func _draw() -> void:
	for rect: Rect2i in rects:
		draw_rect(Rect2(rect.position * 32, rect.size * 32), Color.BLUE.lerp(Color.TRANSPARENT, 0.5), false)
