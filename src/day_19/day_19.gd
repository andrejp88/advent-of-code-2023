class_name Day19

const Util := preload("res://src/util.gd")


func part_1(input: String) -> int:
	var parsed := parse_input(input)
	var wp := WorkflowProcessor.new(parsed[0])

	var running_total := 0
	for part: Dictionary in parsed[1]:
		if wp.process(part):
			running_total += part.values().reduce(Util.sumi)

	return running_total


func part_2(input: String) -> int:
	return 0


func parse_input(input: String) -> Array:
	var workflows: Dictionary = {}
	var parts: Array[Dictionary] = []

	var input_split := input.split("\n\n", false)
	var workflows_source := input_split[0]
	var parts_source := input_split[1]

	var workflow_regex := RegEx.new()
	workflow_regex.compile(r"(\w+)\{((?:\w[><]\d+:\w+,)+)(\w+)\}")

	var condition_regex := RegEx.new()
	condition_regex.compile(r"(\w)([><])(\d+):(\w+)")

	for workflow_source: String in workflows_source.split("\n", false):
		var workflow_match_result := workflow_regex.search(workflow_source)
		var workflow_name := workflow_match_result.get_string(1)
		var workflow_conditions_source := workflow_match_result.get_string(2)
		var workflow_else_name := workflow_match_result.get_string(3)

		var workflow_parsed := []

		var workflow_conditions_source_split := workflow_conditions_source.split(",", false)

		for condition_source: String in workflow_conditions_source_split:
			var condition_match_results := condition_regex.search_all(condition_source)
			for condition_match_result in condition_match_results:
				workflow_parsed.append({
					"cat": condition_match_result.get_string(1),
					"rel": condition_match_result.get_string(2),
					"ref": int(condition_match_result.get_string(3)),
					"next": condition_match_result.get_string(4),
				})

		workflow_parsed.append(workflow_else_name)

		workflows[workflow_name] = workflow_parsed


	var part_regex := RegEx.new()
	part_regex.compile(r"([xmas])=(\d+)")

	for part_source: String in parts_source.split("\n", false):
		var part_parsed := {}

		var match_results := part_regex.search_all(part_source)
		for match_result in match_results:
			part_parsed[match_result.get_string(1)] = int(match_result.get_string(2))

		parts.append(part_parsed)

	return [workflows, parts]


class WorkflowProcessor:

	var workflows: Dictionary


	func _init(p_workflows: Dictionary) -> void:
		workflows = p_workflows


	func process(part: Dictionary) -> bool:

		var next_workflow_name := "in"

		while next_workflow_name not in ["A", "R"]:
			next_workflow_name = pass_part_through_workflow(part, next_workflow_name)

		return next_workflow_name == "A"


	func pass_part_through_workflow(part: Dictionary, workflow_name: String) -> String:

		var workflow: Array = workflows[workflow_name]

		for condition_idx in range(0, workflow.size() - 1):
			var condition: Dictionary = workflow[condition_idx]
			var value_of_category: int = part[condition["cat"]]

			match condition["rel"]:
				">":
					if value_of_category > condition["ref"]:
						return condition["next"]

				"<":
					if value_of_category < condition["ref"]:
						return condition["next"]

				_:
					printerr("Unknown rel in workflow: ", workflow)

		return workflow[workflow.size() - 1]
