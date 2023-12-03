extends Node2D

@onready var tilemap: TileMap = $TileMap
@onready var camera: Camera2D = $Camera2D


func repopulate_tilemap(path: String) -> void:
	tilemap.clear()

	var fa := FileAccess.open(path, FileAccess.READ)
	var data := fa.get_as_text()
	fa.close()

	var lines := data.split("\n", false)

	for line_idx in range(lines.size()):
		var line := lines[line_idx]
		for character_idx in range(line.length()):
			var character := line[character_idx]
			tilemap.set_cell(0, Vector2(character_idx, line_idx), 1, get_atlas_coords(character))


func get_atlas_coords(character: String) -> Vector2:
	match character:
		"0": return Vector2(0, 0)
		"1": return Vector2(1, 0)
		"2": return Vector2(2, 0)
		"3": return Vector2(3, 0)
		"4": return Vector2(4, 0)
		"5": return Vector2(5, 0)
		"6": return Vector2(6, 0)
		"7": return Vector2(7, 0)
		"8": return Vector2(0, 1)
		"9": return Vector2(1, 1)
		"+": return Vector2(2, 1)
		"-": return Vector2(3, 1)
		"*": return Vector2(4, 1)
		"/": return Vector2(5, 1)
		"=": return Vector2(6, 1)
		"@": return Vector2(7, 1)
		"#": return Vector2(0, 2)
		"$": return Vector2(1, 2)
		"%": return Vector2(2, 2)
		"&": return Vector2(3, 2)
		".": return Vector2(6, 7)
		_:
			printerr("Unexpected character: '", character, "'")
			return Vector2(7, 7)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_motion_event := event as InputEventMouseMotion

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			camera.global_position -= (mouse_motion_event.relative) / camera.zoom.x

	elif event is InputEventMouseButton:
		var mouse_button_event := event as InputEventMouseButton

		if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var zoom_factor := camera.zoom * 1.125
			if zoom_factor.x < 20.0:
				camera.zoom = zoom_factor
			if is_equal_approx(camera.zoom.x, 1.0):
				camera.zoom = Vector2.ONE

		elif mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var zoom_factor := camera.zoom / 1.125
			if zoom_factor.x > 1.0 / 20.0:
				camera.zoom = zoom_factor
			if is_equal_approx(camera.zoom.x, 1.0):
				camera.zoom = Vector2.ONE

		elif mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			if not mouse_button_event.pressed:
				camera.global_position = Vector2(roundf(camera.global_position.x), roundf(camera.global_position.y))


func _on_use_test_input_pressed() -> void:
	repopulate_tilemap("res://src/day_3/test_input.txt")


func _on_use_real_input_pressed() -> void:
	repopulate_tilemap("res://src/day_3/input.txt")
