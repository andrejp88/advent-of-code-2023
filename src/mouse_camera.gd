extends Camera2D


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_motion_event := event as InputEventMouseMotion

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			global_position -= (mouse_motion_event.relative) / zoom.x

	elif event is InputEventMouseButton:
		const quintic_root_of_2 := 1.148698354997035 # five steps of the scroll wheel = 2× zoom
		var mouse_button_event := event as InputEventMouseButton

		if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var zoom_factor := zoom * quintic_root_of_2
			if zoom_factor.x < 200.0:
				zoom = zoom_factor
			if is_equal_approx(zoom.x, 1.0):
				zoom = Vector2.ONE

		elif mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var zoom_factor := zoom / quintic_root_of_2
			if zoom_factor.x > 1.0 / 200.0:
				zoom = zoom_factor
			if is_equal_approx(zoom.x, 1.0):
				zoom = Vector2.ONE

		elif mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			if not mouse_button_event.pressed:
				global_position = Vector2(roundf(global_position.x), roundf(global_position.y))
