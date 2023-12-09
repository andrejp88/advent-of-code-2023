class_name Day9

const Util := preload("res://src/util.gd")


func part_1(input: String) -> int:
	var histories := parse_input(input)
	var extrapolated_histories := histories.map(extrapolate_next)
	var last_values := extrapolated_histories.map(func(history: Array[int]) -> int: return history[history.size() - 1])
	var summed: int = last_values.reduce(Util.sumi, 0)
	return summed


func part_2(input: String) -> int:
	return 0


func parse_input(input: String) -> Array:
	var lines := Array(input.split("\n", false))

	var result_as_strings: Array[Array] = []
	result_as_strings.assign(lines.map(
		func(line: String) -> Array[String]:
			var result_inner: Array[String] = []
			result_inner.assign(line.split(" ", false))
			return result_inner
	))

	var result: Array[Array] = []
	result.assign(result_as_strings.map(
		func(line: Array[String]) -> Array[int]:
			var result_inner: Array[int] = []
			result_inner.assign(line.map(
				func(e: String) -> int:
					return int(e)
			))
			return result_inner
	))

	return result


func extrapolate_next(sequence: Array[int]) -> Array[int]:

	if sequence.all(func(e: int) -> bool: return e == 0):
		var result := sequence.duplicate()
		result.push_back(0)
		return result

	else:
		var extrapolated_first_derivative := extrapolate_next(get_first_derivative(sequence))
		var next_value := sequence[sequence.size() - 1] + extrapolated_first_derivative[extrapolated_first_derivative.size() - 1]
		var result := sequence.duplicate()
		result.push_back(next_value)
		return result


func get_first_derivative(sequence: Array[int]) -> Array[int]:
	var result: Array[int] = []

	for idx: int in (sequence.size() - 1):
		result.push_back(sequence[idx + 1] - sequence[idx])

	return result
