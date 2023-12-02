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
			func(round: Array[int]) -> bool:
				return round[0] <= max_red and round[1] <= max_green and round[2] <= max_blue
		)

		if is_game_possible:
			game_id_sum += game_id


	return str(game_id_sum)


func parse_game(game: String) -> Array:
	var segments := game.split(":")
	var rounds := segments[1].split(";")

	return Array(rounds).map(parse_round)


func parse_round(round: String) -> Array[int]:
	return [parse_color(round, "red"), parse_color(round, "green"), parse_color(round, "blue")]


func parse_color(round: String, color: String) -> int:
	var regex := RegEx.new();
	regex.compile(r"\d+ " + color)

	var result := regex.search(round)

	return int(result.get_string()) if result != null else 0
