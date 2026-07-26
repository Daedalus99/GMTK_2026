# currency_ui.gd
extends Node

@onready var currency_label: Label = $"../biomass_count"

# Store the last known amount to calculate the difference
var _last_amount: float = 0.0

@export var float_distance: float = 40.0
@export var float_duration: float = 1.0

func _ready() -> void:
	# Set initial baseline before connecting the signal
	_last_amount = GameManager.player_currency
	_update_display(_last_amount)
	
	# Listen to the global signal whenever it fires
	GameManager.currency_changed.connect(_update_display)

func _update_display(new_amount: float) -> void:
	# Calculate change amount
	var diff: float = floor(new_amount) - floor(_last_amount)
	
	# Update main display text
	currency_label.text = ("x%d" % floor(new_amount))
	
	# Only spawn floating text if the amount actually changed from the last frame
	if diff != 0:
		_spawn_floating_text(diff)
		
	# Keep track of the current value for the next signal fire
	_last_amount = new_amount

func _spawn_floating_text(change: float) -> void:
	var floating_label := Label.new()
	
	# Format the text with a plus sign for positive changes
	if change > 0:
		floating_label.text = "+%d" % change
		floating_label.modulate = Color.GREEN # Optional green highlight
	else:
		floating_label.text = "%d" % change
		floating_label.modulate = Color.RED # Optional red highlight
		
	# Match the theme/font settings from your main label
	var custom_font = currency_label.get_theme_font("font")
	if custom_font:
		floating_label.add_theme_font_override("font", custom_font)
		
	# Add to scene tree safely without inheriting UI layout restrictions
	get_tree().current_scene.add_child(floating_label)
	
	# Position it slightly to the right of your biomass_count label
	floating_label.global_position = currency_label.global_position + Vector2(40, -10)
	
	# Setup the parallel animations
	var tween := create_tween().set_parallel(true)
	
	var target_pos := floating_label.global_position + Vector2(0, -float_distance)
	tween.tween_property(floating_label, "global_position", target_pos, float_duration)
	tween.tween_property(floating_label, "modulate:a", 0.0, float_duration)
	
	# Clear the label from memory when done
	tween.chain().tween_callback(floating_label.queue_free)
