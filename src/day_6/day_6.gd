class_name Day6


func part_1(input: String) -> int:
	var races := parse_input_part_1(input)
	return calc_ways_to_beat_records(races).reduce(func(acc: int, e: int) -> int: return acc * e, 1)


func part_2(input: String) -> int:
	var race := parse_input_part_2(input)
	return calc_ways_to_beat_records([race])[0]


func parse_input_part_1(input: String) -> Array:
	var result := []

	var lines := input.split("\n", false)
	var times := lines[0].split(":")[1].split(" ", false)
	var distances := lines[1].split(":")[1].split(" ", false)

	for i: int in times.size():
		result.push_back([int(times[i]), int(distances[i])])

	return result


func parse_input_part_2(input: String) -> Array[int]:
	var lines := input.split("\n", false)
	return [
		int(lines[0].split(":")[1]),
		int(lines[1].split(":")[1]),
	]


func calc_ways_to_beat_records(races: Array) -> Array[int]:
	var num_ways_to_beat_record_per_race: Array[int] = []

	for race: Array in races:
		var race_time: int = race[0]
		var record_distance: int = race[1]

		# The distance travelled as a function of charge time `x`, given a total race time `t`, is:
		# -x² + tx
		# To get the minimum and maximum charge times needed to set a new record, subtract the
		# current record distance `d`:
		# -x² + tx - d
		# and calculate the roots of this quadratic function.
		# Plug into the classic quadratic formula, with a = -1, b = t, and c = -d
		var roots := get_roots_of_quadratic_equation(-1, race_time, -record_distance)

		# floori/ceili aren't quite right, because they result in charge times that match the record as well as beat it.
		var min_charge_time := next_ceili(roots[0])
		var max_charge_time := next_floori(roots[1])
		#print(min_charge_time, " ~ ", max_charge_time)
		num_ways_to_beat_record_per_race.push_back(max_charge_time - min_charge_time + 1)

	#print(num_ways_to_beat_record_per_race)

	return num_ways_to_beat_record_per_race


func get_distance(total_time: int, charge_time: int) -> int:
	return charge_time * (total_time - charge_time)


func get_roots_of_quadratic_equation(a: float, b: float, c: float) -> Array[float]:
	return [
		(-b + sqrt(b**2 - 4*a*c)) / (2*a),
		(-b - sqrt(b**2 - 4*a*c)) / (2*a),
	]


func next_floori(x: float) -> int:
	if x == floori(x):
		return int(x - 1)
	else:
		return floori(x)


func next_ceili(x: float) -> int:
	if x == ceili(x):
		return int(x + 1)
	else:
		return ceili(x)
