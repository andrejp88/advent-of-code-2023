class_name Day13

const Util := preload("res://src/util.gd")


func part_1(input: String) -> int:

	var blocks := input.split("\n\n", false)

	var result := 0

	for block: String in blocks:
		var rows: Array[String] = []
		rows.assign(Array(block.split("\n", false)))

		# Check for horizontal lines of symmetry (rows)
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
					result += 100 * i
					break


		# Check for vertical lines of symmetry (columns)
		var columns := transpose_lines(rows)
		for i: int in range(1, columns.size()):

			if columns[i] == columns[i - 1]:

				var is_line_of_symmetry := true

				for j: int in (columns.size() - i):
					if i - j - 1 < 0:
						break

					var column_a := columns[i + j]
					var column_b := columns[i - j - 1]

					if column_a != column_b:
						is_line_of_symmetry = false
						break

				if is_line_of_symmetry:
					result += i
					break

	return result


func part_2(input: String) -> int:
	return 0


func transpose_lines(lines: Array[String]) -> Array[String]:
	var result: Array[String] = []

	for i: int in lines[0].length():
		var entry := ""

		for line: String in lines:
			entry += line[i]

		result.append(entry)

	return result
