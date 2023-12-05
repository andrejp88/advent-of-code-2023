class_name Day2


func part_1(s: String) -> String:
	const max_red := 12
	const max_green := 13
	const max_blue := 14

	var games := Array(s.split("\n", false)).map(parse_game)

	var game_id_sum := 0

	for game_index in range(games.size()):
		var game_id := game_index + 1
		var game: Array = games[game_index]
		var is_game_possible := game.all(
			func(round_of_game: Array[int]) -> bool:
				return round_of_game[0] <= max_red and round_of_game[1] <= max_green and round_of_game[2] <= max_blue
		)

		if is_game_possible:
			game_id_sum += game_id


	return str(game_id_sum)


func part_2(s: String) -> String:
	var games := Array(s.split("\n", false)).map(parse_game)

	var powers_of_minimum_sets := games.map(
		func(game: Array) -> int:
			var minimum_set: Array[int] = [0, 0, 0]
			for round_of_game: Array[int] in game:
				minimum_set[0] = maxi(minimum_set[0], round_of_game[0])
				minimum_set[1] = maxi(minimum_set[1], round_of_game[1])
				minimum_set[2] = maxi(minimum_set[2], round_of_game[2])

			return minimum_set.reduce(func(acc: int, e: int) -> int: return acc * e)
	)

	return str(powers_of_minimum_sets.reduce(func(acc: int, e: int) -> int: return acc + e))


func parse_game(game: String) -> Array:
	var segments := game.split(":")
	var rounds := segments[1].split(";")

	return Array(rounds).map(parse_round)


func parse_round(round_source: String) -> Array[int]:
	return [parse_color(round_source, "red"), parse_color(round_source, "green"), parse_color(round_source, "blue")]


func parse_color(round_source: String, color: String) -> int:
	var regex := RegEx.new();
	regex.compile(r"\d+ " + color)

	var result := regex.search(round_source)

	return int(result.get_string()) if result != null else 0
