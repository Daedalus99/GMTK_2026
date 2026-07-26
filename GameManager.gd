extends Node

# Game state variables
var player_currency: float = 0
var level = 1
var salary: float = 0 # currency per second.
var payment_frequency: = 0.5
@onready var base_objective_hp: float = 1_000_000
var timer_set: bool = false
@export var game_stages: Array[Stage]

var curr_objective_hp: float

# Signals for UI updates
signal currency_changed(new_amount: float)
signal salary_changed(new_amount: float)
signal level_up(new_level)

func _ready():
	print("GameManager ready!")
	# Initialize game state
	reset_game()


func reset_game():
	curr_objective_hp = base_objective_hp
	player_currency = 0
	salary = 0
	level = 1
	currency_changed.emit(player_currency)
	salary_changed.emit(salary)

func add_currency(amount: float):
	if amount <=0:
		return
	player_currency += amount
	currency_changed.emit(player_currency)
	check_level_up()
	print("Added %.1f currency: %.1f" % [amount, player_currency])

func spend_currency(amount: float) -> bool:
	if player_currency >= amount:
		print("CHA-CHING! -%.1f biomass, salary=%f" % [amount, salary])
		player_currency -= amount
		currency_changed.emit(player_currency)
		return true
	return false

func check_level_up():
	var required_currency = level * 500  # Adjust as needed
	if player_currency >= required_currency:
		level += 1
		level_up.emit(level)
		print("Level up! Now level ", level)

func get_currency() -> float:
	return player_currency

func _pay_salary():
	print("Paying Salary: %.1f*%.1f = %.1f" % [salary, payment_frequency, (salary*payment_frequency)])
	add_currency(salary*payment_frequency)
	curr_objective_hp -= salary*payment_frequency

func increase_salary(amount: float):
	if not timer_set:
		setup_salary_timer()
		
	print("Increasing salary. %f --> %f" % [salary, salary+amount])
	salary += amount
	salary_changed.emit(salary)

func save_game():
	# TODO: Implement save system
	pass

func load_game():
	# TODO: Implement load system
	pass
	
func setup_salary_timer():
	timer_set = true
	var timer = Timer.new()
	timer.wait_time = payment_frequency
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_pay_salary)
	add_child(timer)
