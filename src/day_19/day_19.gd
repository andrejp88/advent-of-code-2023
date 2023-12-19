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


func get_edges_in(workflows: Dictionary, name: String) -> Dictionary:

	var result := {}

	for workflow_name: String in workflows.keys():
		var workflow_conditions: Array = workflows[workflow_name]

		var winning_combinations: Array[Array] = []

		for condition_idx: int in workflow_conditions.size() - 1:
			var condition: Dictionary = workflow_conditions[condition_idx]

			if condition["next"] == name:
				var conditions_to_fail := workflow_conditions.slice(0, condition_idx)
				var condition_to_succeed := condition.duplicate()
				condition_to_succeed.erase("next")

				winning_combinations.append(conditions_to_fail.map(invert_condition) + [condition_to_succeed])

		if workflow_conditions[workflow_conditions.size() - 1] == name:
			var conditions_to_fail := workflow_conditions.slice(0, workflow_conditions.size() - 1)
			winning_combinations.append(conditions_to_fail.map(invert_condition))

		if not winning_combinations.is_empty():
			result[workflow_name] = winning_combinations

	return result


func invert_workflows_graph(workflows: Dictionary) -> Dictionary:

	var nodes_with_inputs := ["A", "R"] + workflows.keys()
	nodes_with_inputs.erase("in")

	var result := {}

	for node: String in nodes_with_inputs:
		result[node] = get_edges_in(workflows, node)

	return result


func invert_condition(condition: Dictionary) -> Dictionary:
	return {
		"cat": condition["cat"],
		"rel": "<" if condition["rel"] == ">" else ">",
		"ref": condition["ref"] + 1 if condition["rel"] == ">" else condition["ref"] - 1,
	}
