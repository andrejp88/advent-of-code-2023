extends GutTest


var day: Day13


func before_each() -> void:
	day = preload("res://src/day_13/day_13.gd").new()


func test_part_1_example() -> void:
	var fa := FileAccess.open("res://src/day_13/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_1(input), 405)


func test_part_1_real() -> void:
	var fa := FileAccess.open("res://src/day_13/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 13, Part 1: ", day.part_1(input))
	pass_test("passed")


func test_part_2_example() -> void:
	var fa := FileAccess.open("res://src/day_13/test_input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	assert_eq(day.part_2(input), 400)


func test_part_2_slow() -> void:
	var input := (
"#####..########
##.######.####.
.#.#.##.#.#..#.
..###..###....#
...##..##.....#
####....#######
#.#..##..#.##.#
#...#..#...##..
...######......
.#.#....#.#..#.
.###.##.###..##
...######......
###.####.######
#.###..###.##.#
#....##....##..
.#........#..#.
.#.#.##.#.#..#."
	)

	print(day.part_2(input))
	pass_test("passed")


func test_part_2_real() -> void:
	var fa := FileAccess.open("res://src/day_13/input.txt", FileAccess.READ)
	var input := fa.get_as_text()
	fa.close()

	print("Day 13, Part 2: ", day.part_2(input))
	pass_test("passed")


func test_transpose_lines() -> void:
	assert_eq(
		day.transpose_lines([
			"ABCDEFG",
			"HIJKLMN",
			"OPQRSTU",
			"VWXYZ  "
		]),
		[
			"AHOV",
			"BIPW",
			"CJQX",
			"DKRY",
			"ELSZ",
			"FMT ",
			"GNU ",
		]
	)


func test_levenshtein_distance() -> void:
	#var start_time := Time.get_unix_time_from_system()
	assert_eq(day.levenshtein_distance("", ""), 0)
	assert_eq(day.levenshtein_distance("string", "string"), 0)
	assert_eq(day.levenshtein_distance("1", ""), 1)
	assert_eq(day.levenshtein_distance("", "x"), 1)
	assert_eq(day.levenshtein_distance("y", "x"), 1)
	assert_eq(day.levenshtein_distance("kitten", "sitting"), 3)
	assert_eq(day.levenshtein_distance("..###..#..#", "...##..#..#"), 1)
	#assert_eq(day.levenshtein_distance("Supercalifragilisticexpialidocious", "Pneumonoultramicroscopicsilicovolcanoconiosis"), 73) # Too slow lol
	#print("Duration: %4f" % [Time.get_unix_time_from_system() - start_time])


func test_hamming_distance() -> void:
	assert_eq(day.hamming_distance("..###..#..#", "...##..#..#"), 1)
	assert_eq(day.hamming_distance("abcdefghijklmnopqrstuvwxyz", "ancpergtivkxmbodqfshujwlyz"), 12)
	assert_eq(day.hamming_distance("abcdefghijklmnopqrstuvwxyz", "qwertyuiopasdfghjklzxcvbnm"), 26)
