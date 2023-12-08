class_name Day8


func part_1(input: String) -> int:
	var parsed_input := parse_input(input)
	var instructions: String = parsed_input[0]
	var network: Dictionary = parsed_input[1]

	return calculate_distance(network, instructions, "AAA", "ZZZ")


func part_2(input: String) -> int:
	return 0


func parse_input(input: String) -> Array:
	var sections := input.split("\n\n", false)
	var instructions := sections[0]
	var network := {}

	for line: String in sections[1].split("\n", false):
		var regex := RegEx.new()
		regex.compile(r"^([A-Z]{3}) = \(([A-Z]{3}), ([A-Z]{3})\)$")

		var match_result := regex.search(line)
		assert(match_result != null, "RegEx failed to match on line: \"%s\"" % [line])

		var key := match_result.get_string(1)
		var value := [match_result.get_string(2), match_result.get_string(3)]
		network[key] = value

	return [instructions, network]


func calculate_distance(network: Dictionary, instructions: String, start_node: String, end_node: String) -> int:

	var steps_traveled := 0
	var current_node := start_node

	while current_node != end_node:
		var current_instruction_index := steps_traveled % instructions.length()
		var current_instruction := instructions[current_instruction_index]

		match current_instruction:
			"L":
				current_node = network[current_node][0]
			"R":
				current_node = network[current_node][1]

		steps_traveled += 1

	return steps_traveled
