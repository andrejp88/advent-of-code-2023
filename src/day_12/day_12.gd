class_name Day12

const Util := preload("res://src/util.gd")


enum Condition {
	operational,
	damaged,
	unknown,
}


class Row:
	var conditions: Array[Condition]
	var range_sizes: Array[int]

	func _init(p_conditions: Array[Condition], p_range_sizes: Array[int]) -> void:
		self.conditions = p_conditions
		self.range_sizes = p_range_sizes

	func _to_string() -> String:
		return "Row(%s, %s)" % [
			"\"" + conditions.reduce(
				func(acc: String, e: Condition) -> String:
					var symbol := ""
					match e:
						Condition.operational:
							symbol = "."
						Condition.damaged:
							symbol = "#"
						Condition.unknown:
							symbol = "?"
						_:
							printerr("Unknown Condition in match expression: ", e)

					return acc + symbol
					,
					""
			) + "\"",
			range_sizes,
		]


func part_1(input: String) -> int:
	var parsed := parse_input(input)
	var result: int = parsed.map(calculate_possible_arrangements).reduce(Util.sumi)
	return result


func part_2(input: String) -> int:
	return 0


func parse_input(input: String) -> Array[Row]:
	var lines := Array(input.split("\n", false))
	var result: Array[Row] = []
	result.assign(lines.map(parse_row))
	return result


func parse_row(row: String) -> Row:
	var row_split := row.split(" ")
	var conditions_source := row_split[0]
	var range_sizes_source := row_split[1]

	var conditions: Array[Condition] = []

	for condition_symbol: String in conditions_source:
		match condition_symbol:
			".":
				conditions.push_back(Condition.operational)
			"#":
				conditions.push_back(Condition.damaged)
			"?":
				conditions.push_back(Condition.unknown)
			_:
				printerr("Unknown condition symbol: ", condition_symbol)

	var range_sizes: Array[int] = []

	range_sizes.assign(Array(range_sizes_source.split(",")).map(
		func(range_size_source: String) -> int:
			return int(range_size_source)
	))


	return Row.new(conditions, range_sizes)


func calculate_possible_arrangements(row: Row, should_print_debug: bool = false, indent: String = "") -> int:

	if should_print_debug:
		print("%sTesting %s" % [indent, row])

	# 1. Optimization: Fail if total number of damaged entries is wrong
	var num_damaged_actual_in_current_row := row.conditions.count(Condition.damaged)
	var num_damaged_desired_in_current_row: int = row.range_sizes.reduce(Util.sumi, 0)
	var max_damaged_possible_in_current_row: int = row.conditions.count(Condition.damaged) + row.conditions.count(Condition.unknown)

	if (
		num_damaged_actual_in_current_row > num_damaged_desired_in_current_row or
		max_damaged_possible_in_current_row < num_damaged_desired_in_current_row
	):
		# No sub-arrangement can be valid, since they would all have too
		# many or too few damaged entries. This is just an optimization.
		if should_print_debug:
			print("%sSkipping sub-arrangements since there are too many or too few possible damaged entries." % [indent])
		return 0


	# 2. Optimization: Fail if first or last run is the wrong size
	var first_damaged_run_length := 0
	var in_first_damaged_run := false

	for condition: Condition in row.conditions:
		match condition:
			Condition.damaged:
				in_first_damaged_run = true
				first_damaged_run_length += 1

			Condition.operational:
				if in_first_damaged_run:
					if first_damaged_run_length != row.range_sizes[0]:
						if should_print_debug:
							print("%sSkipping sub-arrangements since the first damaged run is the wrong size (%s != %s)" % [indent, first_damaged_run_length, row.range_sizes[0]])
						return 0
					else:
						break

			Condition.unknown:
				break


	var last_damaged_run_length := 0
	var in_last_damaged_run := false
	var row_conditions_reversed := row.conditions.duplicate()
	row_conditions_reversed.reverse()

	for condition: Condition in row_conditions_reversed:
		match condition:
			Condition.damaged:
				in_last_damaged_run = true
				last_damaged_run_length += 1

			Condition.operational:
				if in_last_damaged_run:
					if last_damaged_run_length != row.range_sizes[row.range_sizes.size() - 1]:
						if should_print_debug:
							print("%sSkipping sub-arrangements since the last damaged run is the wrong size (%s != %s)" % [indent, last_damaged_run_length, row.range_sizes[row.range_sizes.size() - 1]])
						return 0
					else:
						break

			Condition.unknown:
				break


	# 3. Get remaining unknown indices
	var indices_of_unknowns: Array[int] = []

	for i: int in row.conditions.size():
		var condition := row.conditions[i]
		if condition == Condition.unknown:
			indices_of_unknowns.push_back(i)


	# 4. No more unknowns left? Check if this is a valid arrangement
	if indices_of_unknowns.is_empty():
		if describe_damaged_ranges(row.conditions) == row.range_sizes:
			if should_print_debug:
				print("%sThis matches!" % [indent])
			return 1
		else:
			# This arrangement isn't valid: There are no unknowns but damaged range description doesn't match
			if should_print_debug:
				print("%sThis doesn't match" % [indent])
			return 0


	# 5. Otherwise, there are still unknowns left so check all possible sub-arrangements
	var num_possible_sub_arrangements := 0

	var with_first_unknown_operational := row.conditions.duplicate()
	with_first_unknown_operational[indices_of_unknowns[0]] = Condition.operational
	var operational_row := Row.new(with_first_unknown_operational, row.range_sizes)
	num_possible_sub_arrangements += calculate_possible_arrangements(operational_row, should_print_debug, indent + "\t")

	var with_first_unknown_damaged := row.conditions.duplicate()
	with_first_unknown_damaged[indices_of_unknowns[0]] = Condition.damaged
	var damaged_row := Row.new(with_first_unknown_damaged, row.range_sizes)
	num_possible_sub_arrangements += calculate_possible_arrangements(damaged_row, should_print_debug, indent + "\t")

	return num_possible_sub_arrangements


func describe_damaged_ranges(conditions: Array[Condition]) -> Array[int]:

	var result: Array[int] = []
	var start_new := true

	for condition: Condition in conditions:
		match condition:
			Condition.operational:
				start_new = true

			Condition.damaged:
				if start_new:
					start_new = false
					result.push_back(1)
				else:
					result[result.size() - 1] += 1

			_:
				printerr("Unexpected Condition in match expression: ", condition)

	return result
