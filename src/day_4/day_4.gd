class_name Day4


func parse_card(card_source: String) -> Dictionary:
	var card_contents := card_source.split(":")[1].split("|")

	var to_int := func(s: String) -> int: return int(s)

	return {
		"winning_numbers": Array(card_contents[0].split(" ", false)).map(to_int),
		"owned_numbers": Array(card_contents[1].split(" ", false)).map(to_int),
	}


func get_number_of_matches(parsed_line: Dictionary) -> int:
	var winning_numbers: Array = parsed_line["winning_numbers"]
	var owned_numbers: Array = parsed_line["owned_numbers"]

	var matching_numbers := 0

	for n: int in owned_numbers:
		for m: int in winning_numbers:
			if n == m:
				matching_numbers += 1

	return matching_numbers


func part_1(input: String) -> int:
	var lines := Array(input.split("\n", false))
	var parsed_lines := lines.map(parse_card)
	var num_matches := parsed_lines.map(get_number_of_matches)
	var points := num_matches.map(
		func(e: int) -> int:
			if e == 0: return 0
			return 2 ** (e - 1)
	)

	var total := points.reduce(func(acc: int, e: int) -> int: return acc + e, 0) as int

	return total
