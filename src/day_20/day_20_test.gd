extends GutTest


var day: Day20


const parsed_test_input_1 := {
	"button": {
		"type": "button",
		"out": ["broadcaster"],
	},
	"broadcaster": {
		"type": "broadcaster",
		"in": ["button"],
		"out": ["a", "b", "c"],
	},
	"a": {
		"type": "%",
		"in": ["broadcaster", "inv"],
		"out": ["b"],
		"state": Day20.OFF,
	},
	"b": {
		"type": "%",
		"in": ["broadcaster", "a"],
		"out": ["c"],
		"state": Day20.OFF,
	},
	"c": {
		"type": "%",
		"in": ["broadcaster", "b"],
		"out": ["inv"],
		"state": Day20.OFF,
	},
	"inv": {
		"type": "&",
		"in": ["c"],
		"out": ["a"],
		"state": { "c": Day20.LOW, }
	},
}

const parsed_test_input_2 := {
	"button": {
		"type": "button",
		"out": ["broadcaster"],
	},
	"broadcaster": {
		"type": "broadcaster",
		"in": ["button"],
		"out": ["a"],
	},
	"a": {
		"type": "%",
		"in": ["broadcaster"],
		"out": ["inv", "con"],
		"state": Day20.OFF,
	},
	"inv": {
		"type": "&",
		"in": ["a"],
		"out": ["b"],
		"state": { "a": Day20.LOW }
	},
	"b": {
		"type": "%",
		"in": ["inv"],
		"out": ["con"],
		"state": Day20.OFF,
	},
	"con": {
		"type": "&",
		"in": ["a", "b"],
		"out": ["output"],
		"state": { "a": Day20.LOW, "b": Day20.LOW },
	},
}


func before_each() -> void:
	day = preload("res://src/day_20/day_20.gd").new()


func test_part_1_example_1() -> void:
	var fa := FileAccess.open("res://src/day_20/test_input_1.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_1(input), 32_000_000)


func test_part_1_example_2() -> void:
	var fa := FileAccess.open("res://src/day_20/test_input_2.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_1(input), 11_687_500)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_20/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 20, Part 1: ", day.part_1(input))
	pass_test("passed")


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_20/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 20, Part 2: ", day.part_2(input))
	pass_test("passed")


func test_parse_input_1() -> void:
	var fa := FileAccess.open("res://src/day_20/test_input_1.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	var result := day.parse_input(input)

	assert_eq(result, parsed_test_input_1)


func test_parse_input_2() -> void:
	var fa := FileAccess.open("res://src/day_20/test_input_2.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	var result := day.parse_input(input)
	assert_eq(result, parsed_test_input_2)


func test_send_pulse_broadcaster() -> void:
	var network_copy := parsed_test_input_1.duplicate(true)
	var network_before_call := network_copy.duplicate(true)
	assert_eq(day.send_pulse(network_copy, Day20.LOW, "button", "broadcaster"), [
		{
			"type": Day20.LOW,
			"from": "broadcaster",
			"to": "a",
		},
		{
			"type": Day20.LOW,
			"from": "broadcaster",
			"to": "b",
		},
		{
			"type": Day20.LOW,
			"from": "broadcaster",
			"to": "c",
		},
	])

	assert_eq(parsed_test_input_1, network_before_call)


func test_send_pulse_flip_flop_low_when_off() -> void:
	var network := parsed_test_input_1.duplicate(true)
	var network_before_call := network.duplicate(true)
	var expected_network_after_call := network.duplicate(true)
	expected_network_after_call["a"]["state"] = Day20.ON

	assert_eq(day.send_pulse(network, Day20.LOW, "broadcaster", "a"), [
		{
			"type": Day20.HIGH,
			"from": "a",
			"to": "b",
		},
	])


	assert_ne(network, network_before_call)
	assert_eq(network, expected_network_after_call)


func test_send_pulse_flip_flop_low_when_on() -> void:
	var network := parsed_test_input_1.duplicate(true)
	network["a"]["state"] = Day20.ON
	var network_before_call := network.duplicate(true)
	var expected_network_after_call := network.duplicate(true)
	expected_network_after_call["a"]["state"] = Day20.OFF

	assert_eq(day.send_pulse(network, Day20.LOW, "broadcaster", "a"), [
		{
			"type": Day20.LOW,
			"from": "a",
			"to": "b",
		},
	])


	assert_ne(network, network_before_call)
	assert_eq(network, expected_network_after_call)


func test_send_pulse_flip_flop_high() -> void:
	var network := parsed_test_input_1.duplicate(true)
	var network_before_call := network.duplicate(true)

	assert_eq(day.send_pulse(network, Day20.HIGH, "broadcaster", "a"), [])
	assert_eq(network, network_before_call)


func test_send_pulse_conjunction_low() -> void:
	var network := parsed_test_input_2.duplicate(true)
	var network_before_call := network.duplicate(true)
	var expected_network_after_call := network.duplicate(true)

	assert_eq(day.send_pulse(network, Day20.LOW, "a", "con"), [
		{
			"type": Day20.HIGH,
			"from": "con",
			"to": "output",
		}
	])

	assert_eq(network, network_before_call)


func test_send_pulse_conjunction_high() -> void:
	var network := parsed_test_input_2.duplicate(true)
	var network_before_call := network.duplicate(true)
	var expected_network_after_call := network.duplicate(true)
	expected_network_after_call["con"]["state"]["a"] = Day20.HIGH

	assert_eq(day.send_pulse(network, Day20.HIGH, "a", "con"), [
		{
			"type": Day20.HIGH,
			"from": "con",
			"to": "output",
		}
	])

	assert_eq(network, expected_network_after_call)


func test_stringify_network_state() -> void:
	assert_eq(day.stringify_network_state(parsed_test_input_1), "a:0,b:0,c:0")
	assert_eq(day.stringify_network_state(parsed_test_input_2), "a:0,b:0")
