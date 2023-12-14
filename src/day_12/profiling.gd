extends Control


var day := preload("res://src/day_12/day_12.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_button_pressed() -> void:
	var row := day.parse_row("???.????.?..????? 3,1,1,3")
	#var row := day.parse_row("?###???????? 3,2,1")
	row.apply_part_2_twist()
	var result := day.calculate_possible_arrangements(row)
	$VBoxContainer/HBoxContainer/Label2.text = str(result)
	#$VBoxContainer/HBoxContainer2/Label2.text = str(day.unique_calls_ddr.size())
	$VBoxContainer/HBoxContainer3/Label2.text = str(day.total_solutions_from_idealized)
	$VBoxContainer/HBoxContainer3/Label4.text = str(day.total_solutions_from_semi_left)
	$VBoxContainer/HBoxContainer3/Label6.text = str(day.total_solutions_from_semi_right)
	$VBoxContainer/HBoxContainer3/Label7.text = str(day.total_solutions_from_non_ideal)
