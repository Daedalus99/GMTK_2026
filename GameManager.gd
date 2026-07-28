extends Node

# Game state variables
var player_currency: float = 0
var salary: float = 0 # currency per second.
var payment_frequency: float = 0.5
var timer_set: bool = false
@export var game_stages: Array[Stage]

var current_stage_index: int = 0
var current_stage: Stage = null
var base_objective_hp: float = 1.0
var curr_objective_hp: float = 1.0

# Signals for UI updates
signal currency_changed(new_amount: float)
signal salary_changed(new_amount: float)
signal stage_changed(new_stage: Stage)

func _ready() -> void:
	reset_game()

func reset_game() -> void:
	_initial_load = true
	current_stage_index = 0
	player_currency = 0
	salary = 0
	_load_stage(0)
	_initial_load = false
	currency_changed.emit(player_currency)
	salary_changed.emit(salary)

# ------------------------------------------------------------------
# Stage management
# ------------------------------------------------------------------

func _load_stage(index: int) -> void:
	if game_stages.is_empty():
		push_warning("GameManager: game_stages array is empty.")
		return
	if index >= game_stages.size():
		print("GameManager: all stages complete!")
		return

	current_stage_index = index
	current_stage = game_stages[index]
	base_objective_hp = current_stage.starting_amount
	curr_objective_hp = base_objective_hp

	if current_stage.reset_salary_on_start:
		salary = 0
		salary_changed.emit(salary)

	print("Stage loaded: %s (hp: %s)" % [current_stage.name, base_objective_hp])
	stage_changed.emit(current_stage)
	
	if not _initial_load:
		if current_stage.stage_scene:
			get_tree().change_scene_to_packed.call_deferred(current_stage.stage_scene)
		else:
			push_warning("GameManager: Stage '%s' has no stage_scene assigned — scene will not change." % current_stage.name)

var _initial_load: bool = true

func _advance_stage() -> void:
	_load_stage(current_stage_index + 1)

func _check_stage_complete() -> void:
	if curr_objective_hp <= 0:
		curr_objective_hp = 0
		currency_changed.emit(player_currency)  # Force UI refresh at exactly 0.
		print("Stage complete: %s" % current_stage.name)
		_advance_stage()

# ------------------------------------------------------------------
# Currency
# ------------------------------------------------------------------

func add_currency(amount: float) -> void:
	if amount <= 0:
		return
	player_currency += amount
	curr_objective_hp -= amount
	currency_changed.emit(player_currency)

func spend_currency(amount: float) -> bool:
	if player_currency >= amount:
		player_currency -= amount
		currency_changed.emit(player_currency)
		return true
	return false

func get_currency() -> float:
	return player_currency

# ------------------------------------------------------------------
# Salary / timer
# ------------------------------------------------------------------

func _pay_salary() -> void:
	var payment := salary * payment_frequency
	add_currency(payment)
	_check_stage_complete()

func increase_salary(amount: float) -> void:
	if not timer_set:
		setup_salary_timer()
	salary += amount
	salary_changed.emit(salary)

func setup_salary_timer() -> void:
	timer_set = true
	var timer := Timer.new()
	timer.wait_time = payment_frequency
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_pay_salary)
	add_child(timer)

func save_game() -> void:
	pass  # TODO

func load_game() -> void:
	pass  # TODO
