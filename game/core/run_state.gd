class_name RunState
extends Node

# Signals
signal run_started
signal target_changed(new_value: float)
signal timer_changed(time_remaining: float)
signal passive_rate_changed(new_rate: float)
signal progress_threshold_reached(threshold: float)
signal run_won
signal run_lost
signal run_restarted

# Run status enum
enum Status {
	NOT_STARTED,
	RUNNING,
	WON,
	LOST,
	PAUSED
}

# Configuration
var current_scenario: ScenarioResource
var starting_target: float
var run_duration: float
var has_timer: bool
var progress_thresholds: Array[float] = []

# Runtime state
var current_target: float
var time_remaining: float
var elapsed_time: float
var run_status: Status = Status.NOT_STARTED
var passive_reduction_rate: float = 0.0
var simulation_paused: bool = false

# Threshold tracking
var _reached_thresholds: Array[float] = []
var _last_displayed_target: float = -1.0
var _last_displayed_time: float = -1.0

# Simulation timing
var _simulation_timer: float = 0.0
const SIMULATION_TICK_RATE: float = 10.0  # Updates per second
const SIMULATION_TICK_INTERVAL: float = 1.0 / SIMULATION_TICK_RATE

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	if run_status != Status.RUNNING or simulation_paused:
		return
	
	# Accumulate time for fixed-tick simulation
	_simulation_timer += delta
	
	# Process simulation ticks
	while _simulation_timer >= SIMULATION_TICK_INTERVAL:
		_simulation_timer -= SIMULATION_TICK_INTERVAL
		_process_simulation_tick(SIMULATION_TICK_INTERVAL)

func _process_simulation_tick(tick_delta: float) -> void:
	# Update timer
	if has_timer:
		time_remaining -= tick_delta
		elapsed_time += tick_delta
		
		if time_remaining <= 0.0:
			time_remaining = 0.0
			_end_run_with_loss()
			return
	else:
		elapsed_time += tick_delta
	
	# Apply passive reduction
	if passive_reduction_rate > 0.0:
		var reduction = passive_reduction_rate * tick_delta
		apply_reduction(reduction)
	
	# Emit timer signal if display value changed significantly
	if has_timer:
		var display_time = ceil(time_remaining)
		if display_time != _last_displayed_time:
			_last_displayed_time = display_time
			timer_changed.emit(time_remaining)

func load_scenario(scenario: ScenarioResource) -> void:
	current_scenario = scenario
	starting_target = scenario.starting_target
	run_duration = scenario.run_duration
	has_timer = scenario.has_timer
	progress_thresholds = scenario.progress_thresholds.duplicate()
	
	# Reset state
	current_target = starting_target
	time_remaining = run_duration
	elapsed_time = 0.0
	passive_reduction_rate = 0.0
	run_status = Status.NOT_STARTED
	_reached_thresholds.clear()
	_last_displayed_target = -1.0
	_last_displayed_time = -1.0

func start_run() -> void:
	if run_status == Status.RUNNING:
		push_warning("Run is already started")
		return
	
	run_status = Status.RUNNING
	simulation_paused = false
	set_process(true)
	run_started.emit()
	
	# Force initial UI updates
	target_changed.emit(current_target)
	if has_timer:
		timer_changed.emit(time_remaining)
	passive_rate_changed.emit(passive_reduction_rate)

func restart_run() -> void:
	if current_scenario == null:
		push_error("No scenario loaded")
		return
	
	load_scenario(current_scenario)
	start_run()
	run_restarted.emit()

func pause_run() -> void:
	if run_status == Status.RUNNING:
		run_status = Status.PAUSED
		simulation_paused = true

func resume_run() -> void:
	if run_status == Status.PAUSED:
		run_status = Status.RUNNING
		simulation_paused = false

func apply_reduction(amount: float) -> void:
	if run_status != Status.RUNNING:
		return
	
	var old_target = current_target
	current_target = max(0.0, current_target - amount)
	
	# Check for win condition
	if current_target <= 0.0:
		_end_run_with_win()
		return
	
	# Check for threshold crossings
	_check_thresholds(old_target, current_target)
	
	# Emit signal if display value changed significantly
	var display_target = _get_display_value(current_target)
	var last_display = _get_display_value(_last_displayed_target)
	if display_target != last_display:
		_last_displayed_target = current_target
		target_changed.emit(current_target)

func set_passive_reduction_rate(rate: float) -> void:
	passive_reduction_rate = max(0.0, rate)
	passive_rate_changed.emit(passive_reduction_rate)

func add_passive_reduction_rate(amount: float) -> void:
	set_passive_reduction_rate(passive_reduction_rate + amount)

# Get progress as 0-1 ratio (1.0 = complete)
func get_progress_ratio() -> float:
	if starting_target <= 0.0:
		return 1.0
	return 1.0 - (current_target / starting_target)

# Get remaining ratio (0.0 = complete)
func get_remaining_ratio() -> float:
	if starting_target <= 0.0:
		return 0.0
	return current_target / starting_target

func _end_run_with_win() -> void:
	current_target = 0.0
	run_status = Status.WON
	set_process(false)
	target_changed.emit(current_target)
	run_won.emit()

func _end_run_with_loss() -> void:
	run_status = Status.LOST
	set_process(false)
	run_lost.emit()

func _check_thresholds(old_value: float, new_value: float) -> void:
	var progress = get_progress_ratio()
	
	for threshold in progress_thresholds:
		if threshold in _reached_thresholds:
			continue
		
		var threshold_target = starting_target * (1.0 - threshold)
		if old_value > threshold_target and new_value <= threshold_target:
			_reached_thresholds.append(threshold)
			progress_threshold_reached.emit(threshold)

# Helper to determine when to update display (reduce update frequency)
func _get_display_value(value: float) -> float:
	# Round to reasonable precision for display updates
	if value >= 1000000:
		return round(value / 10000) * 10000  # Round to 10K
	elif value >= 10000:
		return round(value / 100) * 100      # Round to 100
	elif value >= 1000:
		return round(value / 10) * 10        # Round to 10
	else:
		return round(value)                  # Round to 1