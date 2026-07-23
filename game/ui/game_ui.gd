class_name GameUI
extends Control

# UI References
@onready var target_label: Label = $VBoxContainer/HeaderContainer/TargetLabel
@onready var progress_bar: ProgressBar = $VBoxContainer/HeaderContainer/ProgressBar
@onready var timer_label: Label = $VBoxContainer/HeaderContainer/TimerLabel
@onready var rate_label: Label = $VBoxContainer/StatusContainer/RateLabel
@onready var credits_label: Label = $VBoxContainer/StatusContainer/CreditsLabel
@onready var actions_container: VBoxContainer = $VBoxContainer/ScrollContainer/ActionsContainer
@onready var start_button: Button = $VBoxContainer/ControlsContainer/StartButton
@onready var restart_button: Button = $VBoxContainer/ControlsContainer/RestartButton
@onready var win_overlay: Control = $WinOverlay
@onready var loss_overlay: Control = $LossOverlay
@onready var scenario_label: Label = $VBoxContainer/HeaderContainer/ScenarioLabel

# Game systems
var run_state: RunState
var action_manager: ActionManager
var action_rows: Array[ActionRow] = []

# Action row scene
const ACTION_ROW_SCENE = preload("res://game/ui/action_row.tscn")

func _ready() -> void:
	# Connect UI buttons
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	
	# Hide overlays initially
	if win_overlay:
		win_overlay.visible = false
	if loss_overlay:
		loss_overlay.visible = false

func setup(run_state_ref: RunState, action_manager_ref: ActionManager, scenario: ScenarioResource, action_resources: Array[ActionResource]) -> void:
	run_state = run_state_ref
	action_manager = action_manager_ref
	
	# Connect to signals
	if run_state:
		run_state.target_changed.connect(_on_target_changed)
		run_state.timer_changed.connect(_on_timer_changed)
		run_state.passive_rate_changed.connect(_on_passive_rate_changed)
		run_state.run_won.connect(_on_run_won)
		run_state.run_lost.connect(_on_run_lost)
		run_state.run_started.connect(_on_run_started)
		run_state.run_restarted.connect(_on_run_restarted)
	
	if action_manager:
		action_manager.credits_changed.connect(_on_credits_changed)
		action_manager.action_purchased.connect(_on_action_purchased)
		action_manager.action_unlocked.connect(_on_action_unlocked)
		action_manager.automation_toggled.connect(_on_automation_toggled)
	
	# Display scenario info
	if scenario_label:
		scenario_label.text = scenario.display_name
	
	# Create action rows
	_create_action_rows(action_resources)
	
	# Initialize display
	_update_all_displays()

func _create_action_rows(action_resources: Array[ActionResource]) -> void:
	# Clear existing rows
	for row in action_rows:
		if is_instance_valid(row):
			row.queue_free()
	action_rows.clear()
	
	# Create new rows
	for action_resource in action_resources:
		var row = ACTION_ROW_SCENE.instantiate() as ActionRow
		if row:
			actions_container.add_child(row)
			row.setup(action_resource, action_manager)
			
			# Connect row signals
			row.action_purchased.connect(_on_action_row_purchase)
			row.action_activated.connect(_on_action_row_activate)
			row.automation_toggled.connect(_on_action_row_automation_toggle)
			
			action_rows.append(row)

func _update_all_displays() -> void:
	_update_target_display()
	_update_timer_display()
	_update_rate_display()
	_update_credits_display()
	_update_buttons()
	_update_action_rows()

func _update_target_display() -> void:
	if target_label and run_state:
		target_label.text = "Target: " + NumberFormatter.format_number(run_state.current_target)
	
	if progress_bar and run_state:
		progress_bar.value = run_state.get_progress_ratio()

func _update_timer_display() -> void:
	if timer_label and run_state:
		if run_state.has_timer:
			timer_label.text = "Time: " + NumberFormatter.format_time(run_state.time_remaining)
			timer_label.visible = true
		else:
			timer_label.visible = false

func _update_rate_display() -> void:
	if rate_label and run_state:
		rate_label.text = "Rate: " + NumberFormatter.format_number(run_state.passive_reduction_rate) + "/s"

func _update_credits_display() -> void:
	if credits_label and action_manager:
		credits_label.text = NumberFormatter.format_credits(action_manager.current_credits)

func _update_buttons() -> void:
	if not run_state:
		return
	
	if start_button:
		start_button.visible = run_state.run_status == RunState.Status.NOT_STARTED
	
	if restart_button:
		restart_button.visible = run_state.run_status != RunState.Status.NOT_STARTED

func _update_action_rows() -> void:
	for row in action_rows:
		if is_instance_valid(row):
			row.update_display()

# Signal handlers
func _on_target_changed(new_value: float) -> void:
	_update_target_display()

func _on_timer_changed(time_remaining: float) -> void:
	_update_timer_display()

func _on_passive_rate_changed(new_rate: float) -> void:
	_update_rate_display()

func _on_credits_changed(new_amount: float) -> void:
	_update_credits_display()

func _on_run_won() -> void:
	if win_overlay:
		win_overlay.visible = true

func _on_run_lost() -> void:
	if loss_overlay:
		loss_overlay.visible = true

func _on_run_started() -> void:
	_update_buttons()
	_update_action_rows()

func _on_run_restarted() -> void:
	if win_overlay:
		win_overlay.visible = false
	if loss_overlay:
		loss_overlay.visible = false
	_update_all_displays()

func _on_action_purchased(action_id: String, new_level: int) -> void:
	_update_credits_display()
	_update_action_rows()

func _on_action_unlocked(action_id: String) -> void:
	_update_action_rows()

func _on_automation_toggled(action_id: String, enabled: bool) -> void:
	_update_action_rows()

# UI event handlers
func _on_start_pressed() -> void:
	if run_state:
		run_state.start_run()

func _on_restart_pressed() -> void:
	if run_state:
		run_state.restart_run()

func _on_action_row_purchase(action_id: String) -> void:
	if action_manager:
		action_manager.purchase_action(action_id)

func _on_action_row_activate(action_id: String) -> void:
	if action_manager:
		action_manager.activate_action(action_id)

func _on_action_row_automation_toggle(action_id: String) -> void:
	if action_manager:
		action_manager.toggle_automation(action_id)