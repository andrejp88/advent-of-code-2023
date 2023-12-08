class_name Day8


func part_1(input: String) -> int:
	var parsed_input := parse_input(input)
	var instructions: String = parsed_input[0]
	var network: Dictionary = parsed_input[1]

	return calculate_distance(network, instructions, "AAA", func(node: String) -> bool: return node == "ZZZ")


func part_2(input: String) -> int:
	var parsed_input := parse_input(input)
	var instructions: String = parsed_input[0]
	var network: Dictionary = parsed_input[1]
	var start_nodes: Array[String] = []
	start_nodes.assign(network.keys().filter(func(key: String) -> bool: return key.ends_with("A")))

	# We could rewrite calculate_distance to run concurrently for multiple start nodes, but that's inefficient
	# Instead, calculate how many steps it takes each one individually using the existing calculate_distance,
	# then get the least common multiple of these results.
	# Reminds me of the trick to solving the monkey problem from last year.

	#return calculate_distance_concurrently(network, instructions, start_nodes)

	var steps_per_starting_position: Array[int] = []

	steps_per_starting_position.assign(start_nodes.map(
		func(start_node: String) -> int:
			return calculate_distance(network, instructions, start_node, func(node: String) -> bool: return node.ends_with("Z"))
	))

	return lcm_n(steps_per_starting_position)


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


func calculate_distance(network: Dictionary, instructions: String, start_node: String, end_node_rule: Callable) -> int:

	var steps_traveled := 0
	var current_node := start_node

	while not end_node_rule.call(current_node):
		var current_instruction_index := steps_traveled % instructions.length()
		var current_instruction := instructions[current_instruction_index]

		match current_instruction:
			"L":
				current_node = network[current_node][0]
			"R":
				current_node = network[current_node][1]

		steps_traveled += 1

	return steps_traveled


# Copied from Wikipedia, tested anyway just in case
func gcd(a: int, b: int) -> int:
	while b != 0:
		var t := b
		b = a % b
		a = t

	return a


func lcm(a: int, b: int) -> int:
	# Can ignore this integer_division warnings since gcd(a, b)
	# should be a factor of a, assuming it's implemented right
	@warning_ignore("integer_division")
	return a / gcd(a, b) * b


func lcm_n(ns: Array[int]) -> int:
	return ns.reduce(lcm, 1)
