## cell.gd
## Cell-stage specific behaviour: shader uniform setup and bot ring rotation.
## The parent node should also have clickable_target.gd attached, or this node
## can extend it directly if there is only one script slot needed.
extends ClickableTarget

@onready var bot_circ_container: Node = $CircleContainer

func _ready() -> void:
	# Wait one frame so global_position is finalised before sending to shader.
	await get_tree().process_frame
	initialize_cell_shader(self)
	for chld in get_children():
		if chld is ColorRect:
			initialize_cell_shader(chld)

func initialize_cell_shader(cell: CanvasItem) -> void:
	if not (cell.material is ShaderMaterial):
		push_warning("%s Material is not a ShaderMaterial" % cell)
		return
	print("Setting %s shader settings" % cell)
	var mat = cell.material
	mat.set_shader_parameter("node_world_location", global_position)
	mat.set_shader_parameter("timing_offset", randf()*100)
	mat.set_shader_parameter("speed_mult", (randf()/2) + 1)

func _process(delta: float) -> void:
	# Rotate the little nanobot dudes that are attacking the cell walls
	if bot_circ_container and bot_circ_container.get_child_count() > 1:
		bot_circ_container.rotation_degrees += 10.0 * delta
