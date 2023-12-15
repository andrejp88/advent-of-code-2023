class_name Day15

const Util := preload("res://src/util.gd")


func part_1(input: String) -> int:
	return Array(input.strip_edges().split(",")).map(holiday_hash).reduce(Util.sumi)


func part_2(input: String) -> int:
	return 0


func holiday_hash(input: String) -> int:
	var result := 0

	for idx: int in input.length():
		result += input.unicode_at(idx)
		result *= 17
		result %= 256

	return result
