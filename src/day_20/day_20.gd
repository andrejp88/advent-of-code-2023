class_name Day20

const Util := preload("res://src/util.gd")


const OFF := false
const ON := true
const LOW := 3
const HIGH := 7


func part_1(input: String) -> int:

	var network := parse_input(input)
	var low_pulse_count := 0
	var high_pulse_count := 0

	for i in 1000:
		var pulses_to_send: Array[Dictionary] = [{ "type": LOW, "from": "button", "to": "broadcaster" }]

		while not pulses_to_send.is_empty():
			var current_pulse: Dictionary = pulses_to_send.pop_front()

			if current_pulse["type"] == LOW:
				low_pulse_count += 1
			else:
				high_pulse_count += 1

			if current_pulse["to"] not in network.keys():
				continue


			var next_pulses := send_pulse(network, current_pulse["type"], current_pulse["from"], current_pulse["to"])
			pulses_to_send.append_array(next_pulses)

	return low_pulse_count * high_pulse_count


func part_2(input: String) -> int:
	var network := parse_input(input)

	var button_presses := 0

	var flip_flop_periods := {}

	while true:
		button_presses += 1
		var pulses_to_send: Array[Dictionary] = [{ "type": LOW, "from": "button", "to": "broadcaster" }]

		while not pulses_to_send.is_empty():
			var current_pulse: Dictionary = pulses_to_send.pop_front()

			if current_pulse["to"] not in network.keys():
				if current_pulse["to"] == "rx" and current_pulse["type"] == LOW:
					return button_presses
				continue

			var next_pulses := send_pulse(network, current_pulse["type"], current_pulse["from"], current_pulse["to"])
			pulses_to_send.append_array(next_pulses)

		for module_name: String in network.keys():
			if module_name in ["button", "broadcaster"]:
				continue

			if module_name in flip_flop_periods:
				continue

			if network[module_name]["type"] == "%" and network[module_name]["state"]:
				flip_flop_periods[module_name] = button_presses
				var missing: Array[String] = []
				missing.assign(network.keys().filter(func(key: String) -> bool: return key not in flip_flop_periods and key not in ["button", "broadcaster", "ns"]))
				print("Found %s out of %s flip_flop_periods: %s                missing: %s" % [flip_flop_periods.size(), network.size() - 3, flip_flop_periods, missing])

		if flip_flop_periods.size() == network.keys().filter(func(module_name: String) -> bool: return network[module_name]["type"] == "%").size():
			return get_period(network, flip_flop_periods, "ns")


	return -1


func get_period(network: Dictionary, flip_flop_periods: Dictionary, module_name: String, already_considered: Array[String] = [], indent: String = "") -> int:
	print("%sGetting period of %s" % [indent, module_name])
	if module_name in already_considered:
		return 1

	already_considered.append(module_name)

	var module: Dictionary = network[module_name]
	var result := -1
	if module["type"] == "%":
		print("%sType is %% so fetching result from flip_flop_periods" % [indent])
		result = flip_flop_periods[module_name]

	else:
		print("%sType is & so performing a recursive call" % [indent])
		var recursive_results: Array[int] = []
		result = 1
		for in_module_name: String in module["in"]:
			recursive_results.append(get_period(network, flip_flop_periods, in_module_name, already_considered, indent + "\t"))

		result = recursive_results.reduce(Util.producti)
		if module_name == "ns":
			print(recursive_results)

	print("%sPeriod of %s is %s" % [indent, module_name, result])

	return result


func parse_input(input: String) -> Dictionary:

	var result := {
		"button": {
			"type": "button",
			"out": ["broadcaster"],
		},
	}

	var lines := input.split("\n", false)

	for line: String in lines:
		var line_regex := RegEx.new()
		line_regex.compile(r"(broadcaster|[%&]\w+) -> ((\w+, )*\w+)")
		var line_match := line_regex.search(line)
		var type_and_name_string := line_match.get_string(1)
		var outputs_string := line_match.get_string(2)
		var outputs_list := Array(outputs_string.split(", ", false))

		if type_and_name_string == "broadcaster":
			result["broadcaster"] = {
				"type": "broadcaster",
				"in": ["button"],
				"out": outputs_list,
			}
			continue

		var type := type_and_name_string[0]
		var name := type_and_name_string.substr(1)

		result[name] = {
			"type": type,
			"in": [],
			"out": outputs_list,
		}

		match type:
			"%":
				result[name]["state"] = OFF

			"&":
				result[name]["state"] = {}

			_:
				printerr("Unexpected module type: ", type)


	for module_name: String in result.keys():
		if module_name in ["button", "broadcaster"]:
			continue

		for potential_input_module_name: String in result.keys():
			if potential_input_module_name == module_name:
				continue

			if module_name in result[potential_input_module_name]["out"]:
				result[module_name]["in"].append(potential_input_module_name)

				if result[module_name]["type"] == "&":
					result[module_name]["state"][potential_input_module_name] = LOW

	return result


func send_pulse(network: Dictionary, pulse_type: int, from: String, to: String) -> Array[Dictionary]:
	var next_pulses: Array[Dictionary] = []

	var subject: Dictionary = network[to]

	match subject["type"]:
		"broadcaster":
			next_pulses.assign(subject["out"].map(
				func(dest: String) -> Dictionary:
					return {
						"type": pulse_type,
						"from": to,
						"to": dest,
					}
			))

		"%":
			if pulse_type == LOW:
				if subject["state"] == OFF:
					# For some reason, setting the key directly doesn't work
					subject.merge({ "state": ON }, true)

					next_pulses.assign(subject["out"].map(
						func(dest: String) -> Dictionary:
							return {
								"type": HIGH,
								"from": to,
								"to": dest,
							}
					))

				else:
					# For some reason, setting the key directly doesn't work
					subject.merge({ "state": OFF }, true)

					next_pulses.assign(subject["out"].map(
						func(dest: String) -> Dictionary:
							return {
								"type": LOW,
								"from": to,
								"to": dest,
							}
					))

		"&":
			subject["state"].merge({ from: pulse_type }, true)
			next_pulses.assign(subject["out"].map(
				func(dest: String) -> Dictionary:
					return {
						"type": (
							LOW
							if subject["state"].values().all(func(e: int) -> bool: return e == HIGH) else
							HIGH
						),
						"from": to,
						"to": dest,
					}
			))

		_:
			printerr("Unhandled type: ", subject["type"])

	return next_pulses


func stringify_network_state(network: Dictionary) -> String:
	var pieces: Array[String] = []

	for module_name: String in network.keys():
		var module: Dictionary = network[module_name]
		if module["type"] == "%":
			pieces.append("%s%s" % [module_name, "█" if module["state"] else " "])
		elif module["type"] == "&":
			pieces.append("%s%s" % [module_name, "█" if module["state"].values().all(func(e: int) -> bool: return e == HIGH) else " "])

	return "".join(pieces)
