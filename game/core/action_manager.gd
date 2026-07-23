class_name ActionManager
extends Node

# Signals
signal action_unlocked(action_id: String)
signal action_purchased(action_id: String, new_level: int)
signal action_activated(action_id: String, reduction_amount: float)
signal credits_changed(new_amount: float)
signal automation_toggled(action_id: String, enabled: bool)

# Runtime action state
class ActionState:
	var action_resource: ActionResource
	var current_level: int = 0
	var is_unlocked: bool = false
	var cooldown_remaining: float = 0.0
	var automation_enabled: bool = false
	
	func _init(resource: ActionResource):
		action_resource = resource
		is_unlocked = resource.starts_unlocked

# State
var actions: Dictionary = {}  # action_id -> ActionState
var current_credits: float = 0.0
var run_state: RunState

# Cooldown processing
var _cooldown_timer: float = 0.0
const COOLDOWN_TICK_RATE: float = 10.0
const COOLDOWN_TICK_INTERVAL: float = 1.0 / COOLDOWN_TICK_RATE

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	_cooldown_timer += delta
	
	while _cooldown_timer >= COOLDOWN_TICK_INTERVAL:
		_cooldown_timer -= COOLDOWN_TICK_INTERVAL
		_process_cooldowns(COOLDOWN_TICK_INTERVAL)

func _process_cooldowns(tick_delta: float) -> void:
	for action_state in actions.values():
		if action_state.cooldown_remaining > 0.0:
			action_state.cooldown_remaining = max(0.0, action_state.cooldown_remaining - tick_delta)

func initialize(run_state_ref: RunState, action_resources: Array[ActionResource]) -> void:
	run_state = run_state_ref
	
	# Clear existing actions
	actions.clear()
	
	# Initialize action states
	for action_resource in action_resources:
		var state = ActionState.new(action_resource)
		actions[action_resource.action_id] = state
	
	# Connect to run state signals
	if run_state:
		run_state.progress_threshold_reached.connect(_on_progress_threshold_reached)
		run_state.run_started.connect(_on_run_started)
		run_state.run_restarted.connect(_on_run_restarted)
	
	# Reset credits and automation
	current_credits = 100.0  # Starting credits
	_recalculate_passive_rate()
	credits_changed.emit(current_credits)
	set_process(true)

func _on_run_started() -> void:
	# Reset cooldowns on run start
	for action_state in actions.values():
		action_state.cooldown_remaining = 0.0

func _on_run_restarted() -> void:
	# Reset all action progress on restart
	for action_state in actions.values():
		action_state.current_level = 0
		action_state.is_unlocked = action_state.action_resource.starts_unlocked
		action_state.cooldown_remaining = 0.0
		action_state.automation_enabled = false
	
	current_credits = 100.0
	_recalculate_passive_rate()
	credits_changed.emit(current_credits)

func _on_progress_threshold_reached(threshold: float) -> void:
	# Check for action unlocks
	for action_state in actions.values():
		if not action_state.is_unlocked and action_state.action_resource.unlock_threshold <= threshold:
			action_state.is_unlocked = true
			action_unlocked.emit(action_state.action_resource.action_id)

func can_activate_action(action_id: String) -> bool:
	var action_state = actions.get(action_id)
	if not action_state or not action_state.is_unlocked:
		return false
	
	if action_state.current_level <= 0:
		return false
	
	if action_state.cooldown_remaining > 0.0:
		return false
	
	if not run_state or run_state.run_status != RunState.Status.RUNNING:
		return false
	
	return true

func activate_action(action_id: String) -> bool:
	if not can_activate_action(action_id):
		return false
	
	var action_state = actions[action_id]
	var reduction = action_state.action_resource.get_manual_output_at_level(action_state.current_level)
	
	if reduction > 0.0:
		# Apply cooldown
		action_state.cooldown_remaining = action_state.action_resource.cooldown_duration
		
		# Apply reduction to target
		run_state.apply_reduction(reduction)
		action_activated.emit(action_id, reduction)
		return true
	
	return false

func can_purchase_action(action_id: String) -> bool:
	var action_state = actions.get(action_id)
	if not action_state or not action_state.is_unlocked:
		return false
	
	if action_state.action_resource.is_at_max_level(action_state.current_level):
		return false
	
	var cost = action_state.action_resource.get_cost_for_level(action_state.current_level)
	return current_credits >= cost

func purchase_action(action_id: String) -> bool:
	if not can_purchase_action(action_id):
		return false
	
	var action_state = actions[action_id]
	var cost = action_state.action_resource.get_cost_for_level(action_state.current_level)
	
	# Deduct credits and increase level
	current_credits -= cost
	action_state.current_level += 1
	
	# Update passive rate if this action has automation
	if action_state.action_resource.base_auto_reduction_rate > 0.0:
		_recalculate_passive_rate()
	
	credits_changed.emit(current_credits)
	action_purchased.emit(action_id, action_state.current_level)
	return true

func can_toggle_automation(action_id: String) -> bool:
	var action_state = actions.get(action_id)
	if not action_state or not action_state.is_unlocked:
		return false
	
	if action_state.current_level <= 0:
		return false
	
	# Must have automation capability
	return action_state.action_resource.base_auto_reduction_rate > 0.0

func toggle_automation(action_id: String) -> bool:
	if not can_toggle_automation(action_id):
		return false
	
	var action_state = actions[action_id]
	action_state.automation_enabled = not action_state.automation_enabled
	
	_recalculate_passive_rate()
	automation_toggled.emit(action_id, action_state.automation_enabled)
	return true

func get_action_state(action_id: String) -> ActionState:
	return actions.get(action_id)

func get_next_cost(action_id: String) -> float:
	var action_state = actions.get(action_id)
	if not action_state:
		return 0.0
	return action_state.action_resource.get_cost_for_level(action_state.current_level)

func get_manual_output(action_id: String) -> float:
	var action_state = actions.get(action_id)
	if not action_state:
		return 0.0
	return action_state.action_resource.get_manual_output_at_level(action_state.current_level)

func get_auto_output(action_id: String) -> float:
	var action_state = actions.get(action_id)
	if not action_state:
		return 0.0
	return action_state.action_resource.get_auto_output_at_level(action_state.current_level)

func add_credits(amount: float) -> void:
	current_credits += amount
	credits_changed.emit(current_credits)

func _recalculate_passive_rate() -> void:
	if not run_state:
		return
	
	var total_rate: float = 0.0
	
	for action_state in actions.values():
		if action_state.automation_enabled and action_state.current_level > 0:
			total_rate += action_state.action_resource.get_auto_output_at_level(action_state.current_level)
	
	run_state.set_passive_reduction_rate(total_rate)