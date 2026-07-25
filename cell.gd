extends Control

@onready var bot_circ_container = $CircleContainer

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		cell_clicked()
		# queue_free()  # Remove cell after clicking

func _ready() -> void:
	# Delay to ensure position is set properly
	await get_tree().process_frame
	if material is ShaderMaterial:
		material.set_shader_parameter("node_world_location", global_position)
		print("Set shader uniform to: ", global_position)
	else:
		print("No ShaderMaterial!")

func _process(delta: float) -> void:
	if not bot_circ_container:
		bot_circ_container = $CircleContainer
	if bot_circ_container.get_child_count() <= 1:
		return
	bot_circ_container.rotation_degrees += (10.0*delta)
	

func cell_clicked():
	GameManager.add_currency(1)
