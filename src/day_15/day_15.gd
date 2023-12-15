class_name Day15

const Util := preload("res://src/util.gd")


class Box:
	var lenses: Array[Dictionary]

	func put_lens(label: String, focal_length: int) -> void:
		for lens: Dictionary in lenses:
			if lens["label"] == label:
				lens["focal_length"] = focal_length
				return

		lenses.push_back({ "label": label, "focal_length": focal_length })

	func remove_lens(label: String) -> void:
		var to_remove_idx := -1

		for lens_idx: int in lenses.size():
			if lenses[lens_idx]["label"] == label:
				to_remove_idx = lens_idx
				break

		if to_remove_idx != -1:
			lenses.remove_at(to_remove_idx)



func part_1(input: String) -> int:
	return Array(input.strip_edges().split(",")).map(holiday_hash).reduce(Util.sumi)


func part_2(input: String) -> int:
	var instructions: Array[String] = []
	instructions.assign(input.strip_edges().split(","))

	var boxes: Array[Box] = []
	boxes.resize(256)

	for idx: int in boxes.size():
		boxes[idx] = Day15.Box.new()

	for instruction: String in instructions:
		operate_on_boxes(instruction, boxes)

	var total_focusing_power := 0

	for box_idx: int in boxes.size():
		for lens_idx: int in boxes[box_idx].lenses.size():
			total_focusing_power += (box_idx + 1) * (lens_idx + 1) * boxes[box_idx].lenses[lens_idx]["focal_length"]

	return total_focusing_power


func holiday_hash(input: String) -> int:
	var result := 0

	for idx: int in input.length():
		result += input.unicode_at(idx)
		result *= 17
		result %= 256

	return result


func operate_on_boxes(instruction: String, boxes: Array[Box]) -> void:
	var regex := RegEx.new()
	regex.compile(r"([a-z]+)(-|=([1-9]))")
	var regex_result := regex.search(instruction)
	var label := regex_result.get_string(1)
	var box_idx := holiday_hash(label)

	if regex_result.get_string(2) == "-":
		boxes[box_idx].remove_lens(label)
	else:
		var focal_length := int(regex_result.get_string(3))
		boxes[box_idx].put_lens(label, focal_length)
