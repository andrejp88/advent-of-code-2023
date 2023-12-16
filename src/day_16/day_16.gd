extends Node2D


@onready var tilemap: TileMap = $TileMap
const tilemap_layer_mirrors := 0
const tilemap_layer_light := 1

const tilemap_mirror_atlas_coords := Vector2i(0, 1)
const tilemap_mirrow_nesw_alternative := 0
const tilemap_mirrow_nwse_alternative := 1

const tilemap_splitter_atlas_coords := Vector2i(0, 0)
const tilemap_splitter_v_alternative := 0
const tilemap_splitter_h_alternative := 1

const tilemap_light_atlas_coords := Vector2i(1, 0)
const tilemap_light_v_alternative := 0
const tilemap_light_h_alternative := 1

const tilemap_light_2_ne_atlas_coords := Vector2i(2, 0)
const tilemap_light_2_ne_alternative := 0
const tilemap_light_2_se_alternative := 1
const tilemap_light_2_sw_alternative := 2
const tilemap_light_2_nw_alternative := 3

const tilemap_light_3_nes_atlas_coords := Vector2i(2, 1)
const tilemap_light_3_nes_alternative := 0
const tilemap_light_3_nws_alternative := 1
const tilemap_light_3_wse_alternative := 2
const tilemap_light_3_wne_alternative := 3

const tilemap_light_4_atlas_coords := Vector2i(1, 1)


var should_shine := false
var cells_per_step := 1
var step_duration := 0.01
var time_since_last_step := 0.0
var next_light_stops: Array[Array] = []
var already_visited_light_stops := {}


func _process(delta: float) -> void:
	if next_light_stops.size() > 0:
		time_since_last_step += delta
		while time_since_last_step > step_duration:
			time_since_last_step -= step_duration

			var next_light_stops_candidates: Array[Array] = []

			for stop: Array[Vector2i] in next_light_stops:
				var pos: Vector2i = stop[0]
				var dir: Vector2i = stop[1]

				var cell_data := tilemap.get_cell_tile_data(tilemap_layer_mirrors, pos)

				if cell_data:
					var cell_atlas_coords := tilemap.get_cell_atlas_coords(tilemap_layer_mirrors, pos)
					var cell_alternative := tilemap.get_cell_alternative_tile(tilemap_layer_mirrors, pos)

					match [cell_atlas_coords, cell_alternative, dir]:
						# Mirror /
						[tilemap_mirror_atlas_coords, tilemap_mirrow_nesw_alternative, Vector2i.LEFT]:
							overlay_light(pos, tilemap_light_2_ne_atlas_coords, tilemap_light_2_se_alternative)
							next_light_stops_candidates.append([pos + Vector2i.DOWN, Vector2i.DOWN])

						[tilemap_mirror_atlas_coords, tilemap_mirrow_nesw_alternative, Vector2i.RIGHT]:
							overlay_light(pos, tilemap_light_2_ne_atlas_coords, tilemap_light_2_nw_alternative)
							next_light_stops_candidates.append([pos + Vector2i.UP, Vector2i.UP])

						[tilemap_mirror_atlas_coords, tilemap_mirrow_nesw_alternative, Vector2i.UP]:
							overlay_light(pos, tilemap_light_2_ne_atlas_coords, tilemap_light_2_se_alternative)
							next_light_stops_candidates.append([pos + Vector2i.RIGHT, Vector2i.RIGHT])

						[tilemap_mirror_atlas_coords, tilemap_mirrow_nesw_alternative, Vector2i.DOWN]:
							overlay_light(pos, tilemap_light_2_ne_atlas_coords, tilemap_light_2_nw_alternative)
							next_light_stops_candidates.append([pos + Vector2i.LEFT, Vector2i.LEFT])

						# Mirror \
						[tilemap_mirror_atlas_coords, tilemap_mirrow_nwse_alternative, Vector2i.LEFT]:
							overlay_light(pos, tilemap_light_2_ne_atlas_coords, tilemap_light_2_ne_alternative)
							next_light_stops_candidates.append([pos + Vector2i.UP, Vector2i.UP])

						[tilemap_mirror_atlas_coords, tilemap_mirrow_nwse_alternative, Vector2i.RIGHT]:
							overlay_light(pos, tilemap_light_2_ne_atlas_coords, tilemap_light_2_sw_alternative)
							next_light_stops_candidates.append([pos + Vector2i.DOWN, Vector2i.DOWN])

						[tilemap_mirror_atlas_coords, tilemap_mirrow_nwse_alternative, Vector2i.UP]:
							overlay_light(pos, tilemap_light_2_ne_atlas_coords, tilemap_light_2_sw_alternative)
							next_light_stops_candidates.append([pos + Vector2i.LEFT, Vector2i.LEFT])

						[tilemap_mirror_atlas_coords, tilemap_mirrow_nwse_alternative, Vector2i.DOWN]:
							overlay_light(pos, tilemap_light_2_ne_atlas_coords, tilemap_light_2_ne_alternative)
							next_light_stops_candidates.append([pos + Vector2i.RIGHT, Vector2i.RIGHT])

						# Splitter H
						[tilemap_splitter_atlas_coords, tilemap_splitter_h_alternative, Vector2i.UP]:
							overlay_light(pos, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wse_alternative)
							next_light_stops_candidates.append([pos + Vector2i.LEFT, Vector2i.LEFT])
							next_light_stops_candidates.append([pos + Vector2i.RIGHT, Vector2i.RIGHT])

						[tilemap_splitter_atlas_coords, tilemap_splitter_h_alternative, Vector2i.DOWN]:
							overlay_light(pos, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wne_alternative)
							next_light_stops_candidates.append([pos + Vector2i.LEFT, Vector2i.LEFT])
							next_light_stops_candidates.append([pos + Vector2i.RIGHT, Vector2i.RIGHT])

						[tilemap_splitter_atlas_coords, tilemap_splitter_h_alternative, Vector2i.LEFT]:
							overlay_light(pos, tilemap_light_atlas_coords, tilemap_light_h_alternative)
							next_light_stops_candidates.append([pos + Vector2i.LEFT, Vector2i.LEFT])

						[tilemap_splitter_atlas_coords, tilemap_splitter_h_alternative, Vector2i.RIGHT]:
							overlay_light(pos, tilemap_light_atlas_coords, tilemap_light_h_alternative)
							next_light_stops_candidates.append([pos + Vector2i.RIGHT, Vector2i.RIGHT])

						# Splitter V
						[tilemap_splitter_atlas_coords, tilemap_splitter_v_alternative, Vector2i.LEFT]:
							overlay_light(pos, tilemap_light_3_nes_atlas_coords, tilemap_light_3_nes_alternative)
							next_light_stops_candidates.append([pos + Vector2i.UP, Vector2i.UP])
							next_light_stops_candidates.append([pos + Vector2i.DOWN, Vector2i.DOWN])

						[tilemap_splitter_atlas_coords, tilemap_splitter_v_alternative, Vector2i.RIGHT]:
							overlay_light(pos, tilemap_light_3_nes_atlas_coords, tilemap_light_3_nws_alternative)
							next_light_stops_candidates.append([pos + Vector2i.UP, Vector2i.UP])
							next_light_stops_candidates.append([pos + Vector2i.DOWN, Vector2i.DOWN])

						[tilemap_splitter_atlas_coords, tilemap_splitter_v_alternative, Vector2i.UP]:
							overlay_light(pos, tilemap_light_atlas_coords, tilemap_light_v_alternative)
							next_light_stops_candidates.append([pos + Vector2i.UP, Vector2i.UP])

						[tilemap_splitter_atlas_coords, tilemap_splitter_v_alternative, Vector2i.DOWN]:
							overlay_light(pos, tilemap_light_atlas_coords, tilemap_light_v_alternative)
							next_light_stops_candidates.append([pos + Vector2i.DOWN, Vector2i.DOWN])

						# Other (error)
						_:
							printerr("Unexpected atlas coord and alternative combination: %s" % [[cell_atlas_coords, cell_alternative, dir]])
				else:
					match dir:
						Vector2i.RIGHT, Vector2i.LEFT:
							overlay_light(pos, tilemap_light_atlas_coords, tilemap_light_h_alternative)

						Vector2i.UP, Vector2i.DOWN:
							overlay_light(pos, tilemap_light_atlas_coords, tilemap_light_v_alternative)

						_:
							printerr("Unexpected light direction: %s" % [dir])

					next_light_stops_candidates.append([pos + dir, dir])

				already_visited_light_stops[str(stop)] = true


			next_light_stops.clear()
			next_light_stops.assign(next_light_stops_candidates.filter(
				func(stop: Array) -> bool:
					return tilemap.get_used_rect().has_point(stop[0]) and str(stop) not in already_visited_light_stops
			))


		$CanvasLayer/VBoxContainer/HBoxContainer2/EnergizedCellsCountLabel.text = str(tilemap.get_used_cells(tilemap_layer_light).size())
		if next_light_stops.is_empty():
			$CanvasLayer/VBoxContainer/HBoxContainer2/ShineLightButton.text = "And There Was Light"


func overlay_light(pos: Vector2i, desired_atlas_coords: Vector2i, desired_alternative: int) -> void:
	var current_cell_data := tilemap.get_cell_tile_data(tilemap_layer_light, pos)

	if current_cell_data == null:
		tilemap.set_cell(tilemap_layer_light, pos, 0, desired_atlas_coords, desired_alternative)
		return

	var current_atlas_coords := tilemap.get_cell_atlas_coords(tilemap_layer_light, pos)
	var current_alternative := tilemap.get_cell_alternative_tile(tilemap_layer_light, pos)

	if current_atlas_coords == desired_atlas_coords and current_alternative == desired_alternative:
		return

	if current_atlas_coords == tilemap_light_4_atlas_coords:
		return

	if desired_atlas_coords == tilemap_light_4_atlas_coords:
		tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)
		return

	match current_atlas_coords:
		tilemap_light_atlas_coords:
			match current_alternative:
				tilemap_light_h_alternative:
					match desired_atlas_coords:
						tilemap_light_atlas_coords:
							match desired_alternative:
								tilemap_light_v_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

						tilemap_light_2_ne_atlas_coords:
							match desired_alternative:
								tilemap_light_2_ne_alternative, tilemap_light_2_nw_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wne_alternative)

								tilemap_light_2_se_alternative, tilemap_light_2_sw_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wse_alternative)

						tilemap_light_3_nes_atlas_coords:
							match desired_alternative:
								tilemap_light_3_nes_alternative, tilemap_light_3_nws_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

								tilemap_light_3_wne_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wne_alternative)

								tilemap_light_3_wse_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wse_alternative)

						tilemap_light_4_atlas_coords:
							tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

				tilemap_light_v_alternative:
					match desired_atlas_coords:
						tilemap_light_atlas_coords:
							match desired_alternative:
								tilemap_light_h_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

						tilemap_light_2_ne_atlas_coords:
							match desired_alternative:
								tilemap_light_2_ne_alternative, tilemap_light_2_se_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_nes_alternative)

								tilemap_light_2_nw_alternative, tilemap_light_2_sw_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_nws_alternative)

						tilemap_light_3_nes_atlas_coords:
							match desired_alternative:
								tilemap_light_3_wne_alternative, tilemap_light_3_wse_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

		tilemap_light_2_ne_atlas_coords:
			match current_alternative:
				tilemap_light_2_ne_alternative:
					match desired_atlas_coords:
						tilemap_light_atlas_coords:
							match desired_alternative:
								tilemap_light_h_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wne_alternative)

								tilemap_light_v_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_nes_alternative)

						tilemap_light_2_ne_atlas_coords:
							match desired_alternative:
								tilemap_light_2_nw_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wne_alternative)

								tilemap_light_2_se_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_nes_alternative)

								tilemap_light_2_sw_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

						tilemap_light_3_nes_atlas_coords:
							match desired_alternative:
								tilemap_light_3_nes_alternative, tilemap_light_3_wne_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, desired_alternative)

								tilemap_light_3_nws_alternative, tilemap_light_3_wse_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

				tilemap_light_2_nw_alternative:
					match desired_atlas_coords:
						tilemap_light_atlas_coords:
							match desired_alternative:
								tilemap_light_h_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wne_alternative)

								tilemap_light_v_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_nws_alternative)

						tilemap_light_2_ne_atlas_coords:
							match desired_alternative:
								tilemap_light_2_ne_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wne_alternative)

								tilemap_light_2_se_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

								tilemap_light_2_sw_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_nws_alternative)

						tilemap_light_3_nes_atlas_coords:
							match desired_alternative:
								tilemap_light_3_nws_alternative, tilemap_light_3_wne_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, desired_alternative)

								tilemap_light_3_nes_alternative, tilemap_light_3_wse_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

				tilemap_light_2_se_alternative:
					match desired_atlas_coords:
						tilemap_light_atlas_coords:
							match desired_alternative:
								tilemap_light_h_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wse_alternative)

								tilemap_light_v_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_nes_alternative)

						tilemap_light_2_ne_atlas_coords:
							match desired_alternative:
								tilemap_light_2_ne_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_nes_alternative)

								tilemap_light_2_nw_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

								tilemap_light_2_sw_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wse_alternative)

						tilemap_light_3_nes_atlas_coords:
							match desired_alternative:
								tilemap_light_3_nes_alternative, tilemap_light_3_wse_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, desired_atlas_coords, desired_alternative)

								tilemap_light_3_nws_alternative, tilemap_light_3_wne_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

				tilemap_light_2_sw_alternative:
					match desired_atlas_coords:
						tilemap_light_atlas_coords:
							match desired_alternative:
								tilemap_light_h_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wse_alternative)

								tilemap_light_v_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_nws_alternative)

						tilemap_light_2_ne_atlas_coords:
							match desired_alternative:
								tilemap_light_2_ne_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

								tilemap_light_2_nw_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_nws_alternative)

								tilemap_light_2_se_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_3_nes_atlas_coords, tilemap_light_3_wse_alternative)

						tilemap_light_3_nes_atlas_coords:
							match desired_alternative:
								tilemap_light_3_wse_alternative, tilemap_light_3_nws_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, desired_atlas_coords, desired_alternative)

								tilemap_light_3_nes_alternative, tilemap_light_3_wne_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

		tilemap_light_3_nes_atlas_coords:
			match current_alternative:
				tilemap_light_3_nes_alternative:
					match desired_atlas_coords:
						tilemap_light_atlas_coords:
							match desired_alternative:
								tilemap_light_h_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

						tilemap_light_2_ne_atlas_coords:
							match desired_alternative:
								tilemap_light_2_nw_alternative, tilemap_light_2_sw_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

						tilemap_light_3_nes_atlas_coords:
							match desired_alternative:
								tilemap_light_3_nws_alternative, tilemap_light_3_wne_alternative, tilemap_light_3_wse_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

				tilemap_light_3_nws_alternative:
					match desired_atlas_coords:
						tilemap_light_atlas_coords:
							match desired_alternative:
								tilemap_light_h_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

						tilemap_light_2_ne_atlas_coords:
							match desired_alternative:
								tilemap_light_2_ne_alternative, tilemap_light_2_se_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

						tilemap_light_3_nes_atlas_coords:
							match desired_alternative:
								tilemap_light_3_nes_alternative, tilemap_light_3_wne_alternative, tilemap_light_3_wse_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

				tilemap_light_3_wne_alternative:
					match desired_atlas_coords:
						tilemap_light_atlas_coords:
							match desired_alternative:
								tilemap_light_v_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

						tilemap_light_2_ne_atlas_coords:
							match desired_alternative:
								tilemap_light_2_sw_alternative, tilemap_light_2_se_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

						tilemap_light_3_nes_atlas_coords:
							match desired_alternative:
								tilemap_light_3_nws_alternative, tilemap_light_3_wse_alternative, tilemap_light_3_nes_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

				tilemap_light_3_wse_alternative:
					match desired_atlas_coords:
						tilemap_light_atlas_coords:
							match desired_alternative:
								tilemap_light_v_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

						tilemap_light_2_ne_atlas_coords:
							match desired_alternative:
								tilemap_light_2_nw_alternative, tilemap_light_2_ne_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)

						tilemap_light_3_nes_atlas_coords:
							match desired_alternative:
								tilemap_light_3_nws_alternative, tilemap_light_3_wne_alternative, tilemap_light_3_nes_alternative:
									tilemap.set_cell(tilemap_layer_light, pos, 0, tilemap_light_4_atlas_coords)



func load_and_repopulate_tilemap(path: String) -> void:
	var fa := FileAccess.open(path, FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()
	repopulate_tilemap(input)


func repopulate_tilemap(input: String) -> void:

	$CanvasLayer/VBoxContainer/HBoxContainer2/EnergizedCellsCountLabel.text = "Not Yet Calculated"
	$CanvasLayer/VBoxContainer/HBoxContainer2/ShineLightButton.text = "Let There Be Light"
	$CanvasLayer/VBoxContainer/HBoxContainer2/ShineLightButton.disabled = false
	tilemap.clear()
	next_light_stops.clear()
	already_visited_light_stops.clear()

	var lines := input.split("\n", false)

	for y: int in lines.size():
		var line := lines[y]
		for x: int in line.length():
			var character := line[x]

			match character:
				"/":
					tilemap.set_cell(tilemap_layer_mirrors, Vector2i(x, y), 0, tilemap_mirror_atlas_coords, tilemap_mirrow_nesw_alternative)
				"\\":
					tilemap.set_cell(tilemap_layer_mirrors, Vector2i(x, y), 0, tilemap_mirror_atlas_coords, tilemap_mirrow_nwse_alternative)
				"|":
					tilemap.set_cell(tilemap_layer_mirrors, Vector2i(x, y), 0, tilemap_splitter_atlas_coords, tilemap_splitter_v_alternative)
				"-":
					tilemap.set_cell(tilemap_layer_mirrors, Vector2i(x, y), 0, tilemap_splitter_atlas_coords, tilemap_splitter_h_alternative)


func shine_light() -> void:
	$CanvasLayer/VBoxContainer/HBoxContainer2/ShineLightButton.text = "Illuminating..."
	$CanvasLayer/VBoxContainer/HBoxContainer2/ShineLightButton.disabled = true
	next_light_stops = [[Vector2i.ZERO, Vector2i.RIGHT]]
