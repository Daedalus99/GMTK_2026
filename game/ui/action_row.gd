class_name ActionRow
extends Control

signal action_purchased(action_id: String)
signal action_activated(action_id: String)
signal automation_toggled(action_id: String)

@onready var name_label: Label = $HBoxContainer/NameLabel
@onready var level_label: Label = $HBoxContainer/LevelLabel
@onready var description_label: Label = $HBoxContainer/DescriptionLabel
@onready var output_label: Label = $HBoxContainer/OutputLabel
@onready var cost_label: Label = $HBoxContainer/CostLabel
@onready var purchase_button: Button = $HBoxContainer/PurchaseButton
@onready var activate_button: Button = $HBoxContainer/ActivateButton
@onready var auto_toggle: CheckBox = $HBoxContainer/AutoToggle
@onready var cooldown_progress: ProgressBar = $HBoxContainer/CooldownProgress

var action_id: String
var action_resource: ActionResource
var action_manager: ActionManager

func _ready() -> void:
	if purchase_button:
		purchase_button.pressed.connect(_on_purchase_pressed)
	if activate_button:
		activate_button.pressed.connect(_on_activate_pressed)
	if auto_toggle:
		auto_toggle.toggled.connect(_on_auto_toggled)

func setup(action_res: ActionResource, manager: ActionManager) -> void:
	action_resource = action_res
	action_manager = manager
	action_id = action_res.action_id
	
	if name_label:
		name_label.text = action_res.display_name
	if description_label:
		description_label.text = action_res.description
	
	# Set up automation toggle visibility
	if auto_toggle:
		auto_toggle.visible = action_res.base_auto_reduction_rate > 0.0
	
	# Set up cooldown progress visibility
	if cooldown_progress:
		cooldown_progress.visible = action_res.cooldown_duration > 0.0
		cooldown_progress.max_value = action_res.cooldown_duration
	
	update_display()

func update_display() -> void:
	if not action_manager or action_id.is_empty():
		return
	
	var action_state = action_manager.get_action_state(action_id)
	if not action_state:
		return
	
	# Update level display
	if level_label:
		if action_state.current_level == 0:
			level_label.text = "Not Owned"
		else:
			level_label.text = "Level " + str(action_state.current_level)
	
	# Update output display
	if output_label:
		var manual_output = action_manager.get_manual_output(action_id)
		var auto_output = action_manager.get_auto_output(action_id)
		
		var output_text = ""
		if manual_output > 0.0:
			output_text += "Manual: " + NumberFormatter.format_number(manual_output)
		if auto_output > 0.0:
			if output_text.length() > 0:
				output_text += " | "
			output_text += "Auto: " + NumberFormatter.format_number(auto_output) + "/s"
		
		if output_text.is_empty():
			output_text = "No output"
		
		output_label.text = output_text
	
	# Update cost display
	if cost_label:
		if action_resource.is_at_max_level(action_state.current_level):
			cost_label.text = "MAX LEVEL"
		else:
			var cost = action_manager.get_next_cost(action_id)
			cost_label.text = NumberFormatter.format_credits(cost)
	
	# Update button states
	if purchase_button:
		purchase_button.visible = action_state.is_unlocked
		purchase_button.disabled = not action_manager.can_purchase_action(action_id)
		if action_resource.is_at_max_level(action_state.current_level):
			purchase_button.text = "MAX"
		else:
			purchase_button.text = "Buy" if action_state.current_level == 0 else "Upgrade"
	
	if activate_button:
		activate_button.visible = action_state.is_unlocked and action_resource.base_manual_reduction > 0.0
		activate_button.disabled = not action_manager.can_activate_action(action_id)
		activate_button.text = "Use"
	
	if auto_toggle:
		auto_toggle.visible = action_state.is_unlocked and action_resource.base_auto_reduction_rate > 0.0
		auto_toggle.disabled = not action_manager.can_toggle_automation(action_id)
		auto_toggle.set_pressed_no_signal(action_state.automation_enabled)
	
	# Update cooldown progress
	if cooldown_progress and cooldown_progress.visible:
		cooldown_progress.value = action_state.cooldown_remaining
	
	# Hide entire row if action is not unlocked
	modulate.a = 1.0 if action_state.is_unlocked else 0.5
	mouse_filter = Control.MOUSE_FILTER_PASS if action_state.is_unlocked else Control.MOUSE_FILTER_IGNORE

func _on_purchase_pressed() -> void:
	action_purchased.emit(action_id)

func _on_activate_pressed() -> void:
	action_activated.emit(action_id)

func _on_auto_toggled(button_pressed: bool) -> void:
	automation_toggled.emit(action_id)