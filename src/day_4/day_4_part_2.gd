extends Node2D


var day_4 := preload("res://src/day_4/day_4.gd").new()

@onready var camera: Camera2D = $Camera2D

var parsed_cards: Array
var current_card: int
var card_counts: Array[int] = []


func set_up_from_path(input_path: String) -> void:
	var fa := FileAccess.open(input_path, FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()
	parsed_cards = Array(input.split("\n", false)).map(day_4.parse_card)
	set_up()


func set_up() -> void:
	await get_tree().process_frame

	var card_numbers_container: HBoxContainer = $Board/CardNumbers
	var tokens_container: HBoxContainer = $Board/TokensContainer

	for child: Node in card_numbers_container.get_children():
		child.free()

	for child: Node in tokens_container.get_children():
		child.free()

	for i: int in range(parsed_cards.size()):

		var card_number := i + 1
		var label := Label.new()
		label.text = str(card_number)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.custom_minimum_size.x = 48
		card_numbers_container.add_child(label)


		var this_card_token_container := VBoxContainer.new()
		this_card_token_container.name = "Card %d" % card_number
		this_card_token_container.custom_minimum_size.x = 48
		this_card_token_container.alignment = BoxContainer.ALIGNMENT_END

		var token := TextureRect.new()
		token.texture = preload("res://src/day_4/token.png")
		token.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
		token.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		this_card_token_container.add_child(token)

		tokens_container.add_child(this_card_token_container)

	current_card = 1
	card_counts.resize(parsed_cards.size())
	card_counts.fill(1)
	$CanvasLayer/VBoxContainer/HBoxContainer2/StepButton.disabled = false
	update_labels()


func step() -> void:
	await get_tree().process_frame

	var tokens_container: HBoxContainer = $Board/TokensContainer
	var current_card_idx := current_card - 1

	var num_copies_of_current_card := card_counts[current_card_idx]
	var num_matches := day_4.get_number_of_matches(parsed_cards[current_card_idx])

	for match_idx: int in num_matches:
		card_counts[current_card_idx + 1 + match_idx] += num_copies_of_current_card
		#for copy_idx: int in num_copies_of_current_card:
			#var target_container: VBoxContainer = tokens_container.get_child(current_card_idx + 1 + match_idx)
			#var token := TextureRect.new()
			#token.texture = preload("res://src/day_4/token.png")
			#token.expand_mode = TextureRect.EXPAND_FIT_HEIGHT_PROPORTIONAL
			#token.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			#target_container.add_child(token)

	if current_card == parsed_cards.size():
		$CanvasLayer/VBoxContainer/HBoxContainer2/StepButton.disabled = true
	else:
		current_card += 1
		update_labels()


func update_labels() -> void:
	var card_total := card_counts.reduce(func(acc: int, e: int) -> int: return acc + e, 0) as int
	#var texture_rect_descendants := $Board/TokensContainer.find_children("*", "TextureRect", true, false)
	$CanvasLayer/VBoxContainer/HBoxContainer2/CardCount.text = "Card Count: %d" % card_total
	$CanvasLayer/VBoxContainer/HBoxContainer3/CardCounts.text = "Card Counts: " + str(card_counts)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var mouse_motion_event := event as InputEventMouseMotion

		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			camera.global_position -= (mouse_motion_event.relative) / camera.zoom.x

	elif event is InputEventMouseButton:
		const quintic_root_of_2 := 1.148698354997035 # five steps of the scroll wheel = 2× zoom
		var mouse_button_event := event as InputEventMouseButton

		if mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var zoom_factor := camera.zoom * quintic_root_of_2
			if zoom_factor.x < 20.0:
				camera.zoom = zoom_factor
			if is_equal_approx(camera.zoom.x, 1.0):
				camera.zoom = Vector2.ONE

		elif mouse_button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var zoom_factor := camera.zoom / quintic_root_of_2
			if zoom_factor.x > 1.0 / 20.0:
				camera.zoom = zoom_factor
			if is_equal_approx(camera.zoom.x, 1.0):
				camera.zoom = Vector2.ONE

		elif mouse_button_event.button_index == MOUSE_BUTTON_LEFT:
			if not mouse_button_event.pressed:
				camera.global_position = Vector2(roundf(camera.global_position.x), roundf(camera.global_position.y))

