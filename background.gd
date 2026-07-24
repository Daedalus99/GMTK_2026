extends ColorRect

func _process(delta):
	if material is ShaderMaterial:
		# Usamos la función de Godot 4
		material.set_shader_parameter("resolution", get_viewport_rect().size)
		# material.set_shader_parameter("mouse_pos", get_global_mouse_position()/1000.0)
