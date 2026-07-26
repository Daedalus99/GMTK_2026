## cell.gd
## Cell-stage specific behaviour: shader uniform setup and bot ring rotation.
## The parent node should also have clickable_target.gd attached, or this node
## can extend it directly if there is only one script slot needed.
extends ClickableTarget

@onready var bot_circ_container: Node = $CircleContainer

func _ready() -> void:
	# Wait one frame so global_position is finalised before sending to shader.
	await get_tree().process_frame
	if material is ShaderMaterial:
		material.set_shader_parameter("node_world_location", global_position)
	else:
		push_warning("cell.gd: no ShaderMaterial found on node.")

func _process(delta: float) -> void:
	if bot_circ_container and bot_circ_container.get_child_count() > 1:
		bot_circ_container.rotation_degrees += 10.0 * delta
