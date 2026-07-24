extends Node

# Path to your cursor image asset
const CURSOR_TEXTURE = preload("uid://8wrc51req7m3")
const CURSOR_HOTSPOT = Vector2(0, 0) # Top-left corner pivot point

# PREDICTION TUNING VARIABLES
# 1.0 means predicting exactly 1 frame ahead. Adjust between 1.0 and 2.5 depending on your monitor's V-Sync lag.
const PREDICTION_FACTOR : float = 1.5 
# Prevents the cursor from shaking/jittering when your hand is micro-moving or stationary
const SPEED_DEADZONE : float = 2.0 

var cursor_layer: CanvasLayer
var cursor_sprite: TextureRect
var last_mouse_pos : Vector2 = Vector2.ZERO
var cursor_velocity : Vector2 = Vector2.ZERO

func _ready() -> void:
	Input.use_accumulated_input = false
	# 1. Hide the system hardware mouse cursor completely
	# Input.mouse_mode = Input.MOUSE_MODE_HIDDEN 
	
	cursor_layer = CanvasLayer.new()
	cursor_layer.layer = 128
	add_child(cursor_layer)
	
	cursor_sprite = TextureRect.new()
	cursor_sprite.texture = CURSOR_TEXTURE
	cursor_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cursor_sprite.position = -CURSOR_HOTSPOT
	cursor_layer.add_child(cursor_sprite)
	
	last_mouse_pos = get_viewport().get_mouse_position()
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var current_pos = event.position
		
		# Calculate the directional velocity vector for this individual event step
		cursor_velocity = current_pos - last_mouse_pos
		last_mouse_pos = current_pos
		
		# If moving faster than the deadzone noise floor, extrapolate the future layout
		if cursor_velocity.length() > SPEED_DEADZONE:
			# MATH: Future Position = Present Position + (Directional Velocity * Frame Latency Multiplier)
			var predicted_pos = current_pos + (cursor_velocity * PREDICTION_FACTOR)
			cursor_layer.offset = predicted_pos
		else:
			# If the mouse slows down or stops, instantly snap to true hardware coordinates to kill overshoot
			cursor_layer.offset = current_pos
