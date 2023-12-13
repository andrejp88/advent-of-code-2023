class_name Day13

const Util := preload("res://src/util.gd")


func part_1(input: String) -> int:

	var blocks := input.split("\n\n", false)
	var result := 0

	for block: String in blocks:
		var rows: Array[String] = []
		rows.assign(Array(block.split("\n", false)))
		var rows_result := calculate_lines_of_symmetry_sum(rows)
		result += 100 * rows_result

		if rows_result == 0:
			var columns := transpose_lines(rows)
			result += calculate_lines_of_symmetry_sum(columns)

	return result


func part_2(input: String) -> int:

	var blocks := input.split("\n\n", false)
	var result := 0

	for block: String in blocks:
		var rows: Array[String] = []
		rows.assign(Array(block.split("\n", false)))
		var rows_result := calculate_lines_of_symmetry_sum_with_smudge(rows)
		result += 100 * rows_result

		if rows_result == 0:
			var columns := transpose_lines(rows)
			var columns_result := calculate_lines_of_symmetry_sum_with_smudge(columns)
			result += columns_result

	return result


func calculate_lines_of_symmetry_sum(rows: Array[String]) -> int:
	var result := 0

	for i: int in range(1, rows.size()):

		if rows[i] == rows[i - 1]:

			var is_line_of_symmetry := true

			for j: int in (rows.size() - i):
				if i - j - 1 < 0:
					break

				var row_a := rows[i + j]
				var row_b := rows[i - j - 1]

				if row_a != row_b:
					is_line_of_symmetry = false
					break

			if is_line_of_symmetry:
				result += i
				break

	return result


func calculate_lines_of_symmetry_sum_with_smudge(rows: Array[String]) -> int:
	var result := 0

	for row_idx: int in rows.size():
		var found_new_line_of_symmetry := false
		for potential_pair_idx: int in range(row_idx + 1, rows.size(), 2):
			var hamming_distance_result := hamming_distance(rows[row_idx], rows[potential_pair_idx])
			if hamming_distance_result == 1:
				var new_line_of_symmetry_start := ceili((potential_pair_idx - row_idx) / 2.0) + row_idx
				var is_potential_new_line_of_symmetry := true

				for i: int in rows.size() - new_line_of_symmetry_start:
					if new_line_of_symmetry_start - i - 1 < 0:
						break

					# If row_b (the earlier row) is the semi-matching line we found in the first
					# place, then skip this line since we have already deemed it similar enough.
					if new_line_of_symmetry_start - i - 1 == row_idx:
						continue

					var row_a := rows[new_line_of_symmetry_start + i]
					var row_b := rows[new_line_of_symmetry_start - i - 1]

					if row_a != row_b:
						is_potential_new_line_of_symmetry = false
						break

				if is_potential_new_line_of_symmetry:
					found_new_line_of_symmetry = true
					result += new_line_of_symmetry_start
					break

			if found_new_line_of_symmetry:
				break

		if found_new_line_of_symmetry:
			break

	return result


func transpose_lines(lines: Array[String]) -> Array[String]:
	var result: Array[String] = []

	for i: int in lines[0].length():
		var entry := ""

		for line: String in lines:
			entry += line[i]

		result.append(entry)

	return result


## Adapted from the Python implementation on Wikipedia:
## https://en.wikipedia.org/wiki/Hamming_distance#Algorithm_example
func hamming_distance(a: String, b: String) -> int:
	if a.length() != b.length():
		printerr("Strings must be of equal length.")
		return -1

	var result := 0

	for n in a.length():
		if a[n] != b[n]:
			result += 1

	return result


func levenshtein_distance(a: String, b: String) -> int:
	if a.length() == 0:
		return b.length()

	if b.length() == 0:
		return a.length()

	if a[0] == b[0]:
		return levenshtein_distance(a.substr(1), b.substr(1))

	return 1 + mini(
		mini(
			levenshtein_distance(a, b.substr(1)),
			levenshtein_distance(a.substr(1), b),
		),
		levenshtein_distance(a.substr(1), b.substr(1))
	)
