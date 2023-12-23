extends Node3D


@onready var gridmap: GridMap = $GridMap
var bricks: Array[Array] = []


func load_and_repopulate(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()
	repopulate(input)


func repopulate(input: String) -> void:

	bricks.clear()
	$CanvasLayer/VBoxContainer/HBoxContainer3/Label2.text = "Not Yet Calculated"

	var lines := input.split("\n", false)

	for line in lines:
		var line_parts := line.split("~")
		var brick_start_coords := line_parts[0].split(",")
		var brick_end_coords := line_parts[1].split(",")
		var brick_start := Vector3i(int(brick_start_coords[0]), int(brick_start_coords[2]), int(brick_start_coords[1]))
		var brick_end := Vector3i(int(brick_end_coords[0]), int(brick_end_coords[2]), int(brick_end_coords[1]))

		bricks.push_back([brick_start, brick_end])

	draw_bricks()


func draw_bricks() -> void:

	gridmap.clear()

	for brick: Array[Vector3i] in bricks:

		var brick_axis := (brick[1] - brick[0]).sign()

		for i in int((brick[1] - brick[0]).length() + 1):
			gridmap.set_cell_item(brick[0] + (i * brick_axis), 0)


func apply_gravity() -> void:
	var bricks_from_bottom_to_top := bricks.duplicate()

	bricks_from_bottom_to_top.sort_custom(
		func(brick_a: Array, brick_b: Array) -> bool:
			var brick_a_bottom := mini(brick_a[0].y, brick_a[1].y)
			var brick_b_bottom := mini(brick_b[0].y, brick_b[1].y)
			return brick_b_bottom > brick_a_bottom
	)

	for brick: Array in bricks_from_bottom_to_top:

		var brick_axis: Vector3i = (brick[1] - brick[0]).sign()
		var brick_length := int((brick[1] - brick[0]).length() + 1)

		if brick_axis.y != 0:
			var brick_top := maxi(brick[0].y, brick[1].y)
			var brick_bottom := mini(brick[0].y, brick[1].y)
			var cell_below := Vector3i(brick[0].x, brick_bottom, brick[0].z) + Vector3i.DOWN
			var has_brick_below := cell_below.y < 1 or gridmap.get_cell_item(cell_below) != -1

			while not has_brick_below:
				gridmap.set_cell_item(Vector3i(brick[0].x, brick_top, brick[0].z), GridMap.INVALID_CELL_ITEM)
				gridmap.set_cell_item(Vector3i(brick[0].x, cell_below.y, brick[0].z), 0)

				brick[0].y -= 1
				brick[1].y -= 1

				brick_top = maxi(brick[0].y, brick[1].y)
				brick_bottom = mini(brick[0].y, brick[1].y)
				cell_below = Vector3i(brick[0].x, brick_bottom, brick[0].z) + Vector3i.DOWN
				has_brick_below = cell_below.y < 1 or gridmap.get_cell_item(cell_below) != -1

		else:

			while true:
				var has_brick_below := false

				for i in brick_length:
					var brick_segment: Vector3i = brick[0] + (i * brick_axis)
					var cell_below := brick_segment + Vector3i.DOWN
					if cell_below.y < 1 or gridmap.get_cell_item(cell_below) != -1:
						has_brick_below = true
						break

				if has_brick_below:
					break

				for i in brick_length:
					var brick_segment: Vector3i = brick[0] + (i * brick_axis)
					var cell_below := brick_segment + Vector3i.DOWN

					if cell_below.y < 1 or gridmap.get_cell_item(cell_below) != -1:
						has_brick_below = true

					gridmap.set_cell_item(brick_segment, GridMap.INVALID_CELL_ITEM)
					gridmap.set_cell_item(cell_below, 0)

				brick[0].y -= 1
				brick[1].y -= 1


func count_breakable_bricks() -> void:

	$CanvasLayer/VBoxContainer/HBoxContainer3/Label2.text = "0"

	for brick: Array in bricks:
		var brick_axis: Vector3i = (brick[1] - brick[0]).sign()
		var cells_in_this_brick := get_cells_in_brick(brick)

		if brick_axis.y != 0:
			var brick_top := maxi(brick[0].y, brick[1].y)
			var position_above := Vector3i(brick[0].x, brick_top, brick[0].z) + Vector3i.UP
			var cell_above := gridmap.get_cell_item(position_above)

			if cell_above == GridMap.INVALID_CELL_ITEM:
				print("Brick %s is breakable" % [brick])
				$CanvasLayer/VBoxContainer/HBoxContainer3/Label2.text = str(int($CanvasLayer/VBoxContainer/HBoxContainer3/Label2.text) + 1)
				continue

			var brick_above: Array[Vector3i] = []

			for potential_brick_above: Array in bricks:
				var cells_in_potential_brick := get_cells_in_brick(potential_brick_above)

				if position_above in cells_in_potential_brick:
					brick_above.assign(potential_brick_above)
					break

			assert(brick_above != [])

			var brick_above_axis: Vector3i = (brick_above[1] - brick_above[0]).sign()
			var brick_above_length := int((brick_above[1] - brick_above[0]).length() + 1)

			if brick_above_axis.y != 0:
				continue

			var has_other_brick_below := false

			var cells_in_brick_above := get_cells_in_brick(brick_above)

			for cell_in_brick_above in cells_in_brick_above:
				var cell_below_cell_in_brick_above := cell_in_brick_above + Vector3i.DOWN
				if (
					cell_below_cell_in_brick_above != Vector3i(brick[0].x, brick_top, brick[0].z) and
					gridmap.get_cell_item(cell_below_cell_in_brick_above) != -1
				):
					has_other_brick_below = true
					break

			if has_other_brick_below:
				print("Brick %s is breakable" % [brick])
				$CanvasLayer/VBoxContainer/HBoxContainer3/Label2.text = str(int($CanvasLayer/VBoxContainer/HBoxContainer3/Label2.text) + 1)


		else:
			var can_be_broken := true

			for brick_segment in cells_in_this_brick:
				var position_above := brick_segment + Vector3i.UP
				var cell_above := gridmap.get_cell_item(position_above)

				if cell_above == GridMap.INVALID_CELL_ITEM:
					continue

				var brick_above: Array[Vector3i] = []

				for potential_brick_above: Array in bricks:
					var cells_in_potential_brick := get_cells_in_brick(potential_brick_above)

					if position_above in cells_in_potential_brick:
						brick_above.assign(potential_brick_above)
						break

				assert(brick_above != [])

				var brick_above_axis: Vector3i = (brick_above[1] - brick_above[0]).sign()
				var brick_above_length := int((brick_above[1] - brick_above[0]).length() + 1)

				if brick_above_axis.y != 0:
					can_be_broken = false
					break

				var has_other_brick_below := false

				for j in brick_above_length:
					var brick_above_segment: Vector3i = brick_above[0] + (j * brick_above_axis)
					var cell_below_brick_above := brick_above_segment + Vector3i.DOWN
					if cell_below_brick_above not in cells_in_this_brick and gridmap.get_cell_item(cell_below_brick_above) != -1:
						has_other_brick_below = true
						break

				if not has_other_brick_below:
					can_be_broken = false
					break


			if can_be_broken:
				print("Brick %s is breakable" % [brick])
				$CanvasLayer/VBoxContainer/HBoxContainer3/Label2.text = str(int($CanvasLayer/VBoxContainer/HBoxContainer3/Label2.text) + 1)


func get_cells_in_brick(brick: Array) -> Array[Vector3i]:
	var brick_axis: Vector3i = (brick[1] - brick[0]).sign()
	var brick_length := int((brick[1] - brick[0]).length() + 1)
	var result: Array[Vector3i] = []

	for i in brick_length:
		result.append(brick[0] + (i * brick_axis))

	return result
