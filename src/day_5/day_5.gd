class_name Day5


func parse_input(input: String) -> Dictionary:

	var result := {}

	var input_sections := input.split("\n\n")

	result["seeds"] = Array(input_sections[0].get_slice(": ", 1).split(" ")).map(to_int)
	result["seed-to-soil"] = parse_mapping_section(input_sections[1])
	result["soil-to-fertilizer"] = parse_mapping_section(input_sections[2])
	result["fertilizer-to-water"] = parse_mapping_section(input_sections[3])
	result["water-to-light"] = parse_mapping_section(input_sections[4])
	result["light-to-temperature"] = parse_mapping_section(input_sections[5])
	result["temperature-to-humidity"] = parse_mapping_section(input_sections[6])
	result["humidity-to-location"] = parse_mapping_section(input_sections[7])

	return result


func to_int(s: String) -> int:
	return int(s)


func parse_mapping_section(section: String) -> Dictionary:
	var result := {}
	var lines := section.get_slice(":\n", 1).split("\n", false)

	for line: String in lines:
		var numbers := line.split(" ")
		result[[int(numbers[1]), int(numbers[2])]] = int(numbers[0])

	return result


func get_location_for_seed(almanac: Dictionary, seed_number: int) -> int:

	var soil := apply_mapping(almanac["seed-to-soil"], seed_number)
	var fertilizer := apply_mapping(almanac["soil-to-fertilizer"], soil)
	var water := apply_mapping(almanac["fertilizer-to-water"], fertilizer)
	var light := apply_mapping(almanac["water-to-light"], water)
	var temperature := apply_mapping(almanac["light-to-temperature"], light)
	var humidity := apply_mapping(almanac["temperature-to-humidity"], temperature)
	var location := apply_mapping(almanac["humidity-to-location"], humidity)

	# Debug print statement for showing the current seed's journey
	#print(
		#" -> ".join(PackedStringArray([seed_number, soil, fertilizer, water, light, temperature, humidity, location].map(to_str))),
	#)

	return location


func get_seed_for_location(almanac: Dictionary, location: int) -> int:

	var humidity := apply_inverse_mapping(almanac["humidity-to-location"], location)
	var temperature := apply_inverse_mapping(almanac["temperature-to-humidity"], humidity)
	var light := apply_inverse_mapping(almanac["light-to-temperature"], temperature)
	var water := apply_inverse_mapping(almanac["water-to-light"], light)
	var fertilizer := apply_inverse_mapping(almanac["fertilizer-to-water"], water)
	var soil := apply_inverse_mapping(almanac["soil-to-fertilizer"], fertilizer)
	var seed_number := apply_inverse_mapping(almanac["seed-to-soil"], soil)

	# Debug print statement for showing the current seed's journey
	#print(
		#" -> ".join(PackedStringArray([location, humidity, temperature, light, water, fertilizer, soil, seed_number].map(to_str))),
	#)

	return seed_number


func apply_mapping(mapping: Dictionary, value: int) -> int:
	for source_range: Array in mapping:
		var destination_start: int = mapping[source_range]

		if value >= source_range[0] and value < (source_range[0] + source_range[1]):
			return destination_start + (value - source_range[0])

	return value


func apply_inverse_mapping(mapping: Dictionary, value: int) -> int:
	for source_range: Array in mapping:
		var destination_start: int = mapping[source_range]

		if value >= destination_start and value < (destination_start + source_range[1]):
			return source_range[0] + (value - destination_start)

	return value


func to_str(n: int) -> String: return str(n)


func max_value_in_mapping(mapping: Dictionary) -> int:
	var result := 0

	for source_range: Array in mapping:
		var max_in_this_range := maxi(source_range[0] + source_range[1], mapping[source_range] + source_range[1])
		if max_in_this_range > result:
			result = max_in_this_range

	return result


func part_1(input: String) -> int:
	var almanac := parse_input(input)
	var locations := (almanac["seeds"] as Array).map(
		func(seed_number: int) -> int:
			return get_location_for_seed(almanac, seed_number)
	)

	locations.sort()
	return locations[0]


func part_2(input: String) -> int:
	var almanac := parse_input(input)
	var seed_ranges := []

	for seed_idx: int in range(0, almanac["seeds"].size(), 2):
		seed_ranges.push_back([almanac["seeds"][seed_idx], almanac["seeds"][seed_idx + 1]])

	var max_possible_anything := 0
	max_possible_anything = maxi(max_possible_anything, max_value_in_mapping(almanac["humidity-to-location"]))
	max_possible_anything = maxi(max_possible_anything, max_value_in_mapping(almanac["temperature-to-humidity"]))
	max_possible_anything = maxi(max_possible_anything, max_value_in_mapping(almanac["light-to-temperature"]))
	max_possible_anything = maxi(max_possible_anything, max_value_in_mapping(almanac["water-to-light"]))
	max_possible_anything = maxi(max_possible_anything, max_value_in_mapping(almanac["fertilizer-to-water"]))
	max_possible_anything = maxi(max_possible_anything, max_value_in_mapping(almanac["soil-to-fertilizer"]))
	max_possible_anything = maxi(max_possible_anything, max_value_in_mapping(almanac["seed-to-soil"]))

	for location_candidate: int in max_possible_anything:
		var seed_candidate := get_seed_for_location(almanac, location_candidate)

		for seed_range: Array in seed_ranges:
			if seed_candidate >= seed_range[0] and seed_candidate < (seed_range[0] + seed_range[1]):
				return location_candidate

	printerr("Could not find a suitable location 😨")
	return -1

	# The following is a much slower version that iterates over all seeds and finds the minimal location
	# Its runtime is always proportional to the number of seed_numbers.
	# The actual solution above instead iterates over all possible locations and returns the first one
	# that corresponds to an actual seed. Its worst-case runtime is even worse, proportional to the
	# number of possible locations, but I just banked on the assumption that the locations won't all be
	# squashed towards the end of the possible range.

	#for seed_range: Array in seed_ranges:
		#for seed_offset: int in seed_range[1]:
			#var current_seed: int = seed_range[0] + seed_offset
			#var current_location := get_location_for_seed(almanac, current_seed)
			#if minimum_location_seen_so_far == -1 or current_location < minimum_location_seen_so_far:
				#minimum_location_seen_so_far = current_location
				#print(minimum_location_seen_so_far)
#
	#return minimum_location_seen_so_far
