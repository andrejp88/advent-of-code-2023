extends Node2D


var polygon: PackedVector2Array:
	set(value):
		polygon = value
		queue_redraw()


func _draw() -> void:
	if self.polygon.size() > 0:
		var to_draw := self.polygon.duplicate()
		to_draw.append(self.polygon[0])
		draw_polyline(to_draw, Color.GOLDENROD.lerp(Color.TRANSPARENT, 0.5))

		draw_circle(to_draw[0], 4.0, Color.FIREBRICK.lerp(Color.TRANSPARENT, 0.2))

		for vertex: Vector2 in to_draw:
			draw_circle(vertex, 4.0, Color.YELLOW.lerp(Color.TRANSPARENT, 0.2))
