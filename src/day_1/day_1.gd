extends Node


func get_calibration_value_part_1(s: String) -> int:
	var regex := RegEx.new()
	regex.compile(r"\d")
	var results := regex.search_all(s)
	var two_digit_string: String = results.front().get_string() + results.back().get_string()
	return int(two_digit_string)


func get_calibration_value_part_2(s: String) -> int:
	var regex_forward := RegEx.new()
	regex_forward.compile(r"\d|one|two|three|four|five|six|seven|eight|nine")
	var results_forward := regex_forward.search_all(s)

	var regex_backward := RegEx.new()
	regex_backward.compile(r"\d|eno|owt|eerht|ruof|evif|xis|neves|thgie|enin")
	var results_backward := regex_backward.search_all(s.reverse())

	var first_digit: String = results_forward.front().get_string()
	var last_digit: String = results_backward.front().get_string()

	var two_digit_string: String = name_to_digit(first_digit) + name_to_digit(last_digit.reverse())
	return int(two_digit_string)


func name_to_digit(s: String) -> String:
	match s:
		"one": return "1"
		"two": return "2"
		"three": return "3"
		"four": return "4"
		"five": return "5"
		"six": return "6"
		"seven": return "7"
		"eight": return "8"
		"nine": return "9"
		_: return s


func part_1(s: String) -> int:
	var lines := Array(s.split("\n", false))
	var cal_vals := lines.map(get_calibration_value_part_1)
	return cal_vals.reduce(func(acc: int, e: int) -> int: return acc + e)


func part_2(s: String) -> int:
	var lines := Array(s.split("\n", false))
	var cal_vals := lines.map(get_calibration_value_part_2)
	return cal_vals.reduce(func(acc: int, e: int) -> int: return acc + e)
