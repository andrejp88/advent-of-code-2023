class_name Day4


func parse_card(card_source: String) -> Dictionary:
	var card_contents := card_source.split(":")[1].split("|")

	var to_int := func(s: String) -> int: return int(s)

	return {
		"winning_numbers": Array(card_contents[0].split(" ", false)).map(to_int),
		"owned_numbers": Array(card_contents[1].split(" ", false)).map(to_int),
	}


func get_point_value_of_line(line: String) -> int:
	var line_parsed := parse_card(line)
	var winning_numbers: Array = line_parsed["winning_numbers"]
	var owned_numbers: Array = line_parsed["owned_numbers"]

	var shared_numbers := 0

	for n: int in owned_numbers:
		for m: int in winning_numbers:
			if n == m:
				shared_numbers += 1

	if shared_numbers == 0:
		return 0

	return 2 ** (shared_numbers - 1)


func part_1(input: String) -> int:
	var lines := Array(input.split("\n", false))
	var points := lines.map(get_point_value_of_line)
	var total := points.reduce(func(acc: int, e: int) -> int: return acc + e, 0) as int

	return total
