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


func apply_mapping(mapping: Dictionary, value: int) -> int:
	for source_range: Array in mapping:
		var destination_start: int = mapping[source_range]

		if value >= source_range[0] and value < (source_range[0] + source_range[1]):
			return destination_start + (value - source_range[0])

	return value


func to_str(n: int) -> String: return str(n)


func part_1(input: String) -> int:
	var almanac := parse_input(input)
	var locations := (almanac["seeds"] as Array).map(
		func(seed_number: int) -> int:
			return get_location_for_seed(almanac, seed_number)
	)

	locations.sort()
	return locations[0]
