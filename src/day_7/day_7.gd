class_name Day7


enum HandType {
	high_card,
	one_pair,
	two_pair,
	three_of_a_kind,
	full_house,
	four_of_a_kind,
	five_of_a_kind,
}

const rank_to_index_part_1 := {
	"2": 0,
	"3": 1,
	"4": 2,
	"5": 3,
	"6": 4,
	"7": 5,
	"8": 6,
	"9": 7,
	"T": 8,
	"J": 9,
	"Q": 10,
	"K": 11,
	"A": 12,
}

const rank_to_index_part_2 := {
	"J": 0,
	"2": 1,
	"3": 2,
	"4": 3,
	"5": 4,
	"6": 5,
	"7": 6,
	"8": 7,
	"9": 8,
	"T": 9,
	"Q": 10,
	"K": 11,
	"A": 12,
}


func part_1(input: String) -> int:
	var lines := Array(input.split("\n", false))
	return calculate_winnings(lines, get_hand_type_part_1, rank_to_index_part_1)


func part_2(input: String) -> int:
	var lines := Array(input.split("\n", false))
	return calculate_winnings(lines, get_hand_type_part_2, rank_to_index_part_2)


func calculate_winnings(lines: Array, get_hand_type_fn: Callable, rank_to_index_mapping: Dictionary) -> int:
	lines.sort_custom(
		func(a: String, b: String) -> bool:
			var a_hand := a.get_slice(" ", 0)
			var b_hand := b.get_slice(" ", 0)

			var a_hand_type: HandType = get_hand_type_fn.call(a_hand)
			var b_hand_type: HandType = get_hand_type_fn.call(b_hand)

			if a_hand_type != b_hand_type:
				return a_hand_type < b_hand_type

			for i in 5:
				var a_card := a_hand[i]
				var b_card := b_hand[i]

				if a_card != b_card:
					return rank_to_index_mapping[a_card] < rank_to_index_mapping[b_card]

			# At this point they are equal and we can do whatever I guess
			assert(a_hand == b_hand, "Expected both hands to be equal but they're still different: a = %s, b = %s" % [a_hand, b_hand])
			return false
	)

	var total_winnings := 0
	var current_rank := 1

	while current_rank <= lines.size():
		var line: String = lines[current_rank - 1]
		var bid := int(line.get_slice(" ", 1))
		total_winnings += bid * current_rank
		current_rank += 1

	return total_winnings


func get_hand_type_part_1(hand: String) -> HandType:
	var counts: Array[int] = []
	counts.resize(13)
	counts.fill(0)

	for card: String in hand:
		counts[rank_to_index_part_1[card]] += 1

	var hand_descriptor := counts.filter(func(count: int) -> bool: return count != 0)
	hand_descriptor.sort()
	hand_descriptor.reverse()

	var hand_descriptor_sum: int = hand_descriptor.reduce(func(acc: int, e: int) -> int: return acc + e, 0)

	assert(hand_descriptor_sum == 5, "hand_descriptor was expected to sum to five, but actually looks like: %s" % [hand_descriptor])

	match hand_descriptor:
		[5]: return HandType.five_of_a_kind
		[4, 1]: return HandType.four_of_a_kind
		[3, 2]: return HandType.full_house
		[3, 1, 1]: return HandType.three_of_a_kind
		[2, 2, 1]: return HandType.two_pair
		[2, 1, 1, 1]: return HandType.one_pair
		[1, 1, 1, 1, 1]: return HandType.high_card

		_:
			printerr("Unexpected hand_descriptor: ", hand_descriptor)
			return HandType.high_card


func get_hand_type_part_2(hand: String) -> HandType:
	var counts: Array[int] = []
	counts.resize(13)
	counts.fill(0)

	var num_jokers := 0

	for card: String in hand:
		if card == "J":
			num_jokers += 1
		else:
			counts[rank_to_index_part_2[card]] += 1

	var hand_descriptor := counts.filter(func(count: int) -> bool: return count != 0)
	hand_descriptor.sort()
	hand_descriptor.reverse()

	var hand_descriptor_sum: int = hand_descriptor.reduce(func(acc: int, e: int) -> int: return acc + e, 0)

	assert(
		hand_descriptor_sum + num_jokers == 5,
		"hand_descriptor_sum + num_jokers was expected to equal five, but hand_descriptor is %s and there are %s jokers." % [hand_descriptor, num_jokers]
	)

	match [num_jokers, hand_descriptor]:
		[0, [5]]: return HandType.five_of_a_kind
		[0, [4, 1]]: return HandType.four_of_a_kind
		[0, [3, 2]]: return HandType.full_house
		[0, [3, 1, 1]]: return HandType.three_of_a_kind
		[0, [2, 2, 1]]: return HandType.two_pair
		[0, [2, 1, 1, 1]]: return HandType.one_pair
		[0, [1, 1, 1, 1, 1]]: return HandType.high_card

		[1, [4]]: return HandType.five_of_a_kind
		[1, [3, 1]]: return HandType.four_of_a_kind
		[1, [2, 2]]: return HandType.full_house
		[1, [2, 1, 1]]: return HandType.three_of_a_kind
		[1, [1, 1, 1, 1]]: return HandType.one_pair

		[2, [3]]: return HandType.five_of_a_kind
		[2, [2, 1]]: return HandType.four_of_a_kind
		[2, [1, 1, 1]]: return HandType.three_of_a_kind

		[3, [2]]: return HandType.five_of_a_kind
		[3, [1, 1]]: return HandType.four_of_a_kind

		[4, [1]]: return HandType.five_of_a_kind
		[5, []]: return HandType.five_of_a_kind

		_:
			printerr("Unexpected hand_descriptor/joker combination: ", hand_descriptor, " with ", num_jokers, " jokers")
			return HandType.high_card
