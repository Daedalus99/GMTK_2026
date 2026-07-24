extends Control

signal cell_clicked
var biomass_value = 10

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		cell_clicked.emit()
		print("Cell clicked! Gained ", biomass_value, " biomass")
		queue_free()  # Remove cell after clicking

func _ready() -> void:
	# Delay to ensure position is set properly
	await get_tree().process_frame
	if material is ShaderMaterial:
		material.set_shader_parameter("node_world_location", global_position)
		print("Set shader uniform to: ", global_position)
	else:
		print("No ShaderMaterial!")
