extends Node

# Game state variables
var player_currency: float = 0
var level = 1
var salary: float = 0 # currency per second.
var payment_frequency: = 0.5
var upgrades = {}

# Signals for UI updates
signal currency_changed(new_amount)
signal level_up(new_level)

func _ready():
	print("GameManager ready!")
	# Initialize game state
	reset_game()
	setup_salary_timer()

func reset_game():
	player_currency = 0
	salary = 0
	level = 1
	upgrades = {}
	currency_changed.emit(player_currency)

func add_currency(amount: float):
	if amount <=0:
		return
	player_currency += amount
	currency_changed.emit(player_currency)
	check_level_up()
	print("Added %d currency: %d" % [amount, player_currency])

func spend_currency(amount: float) -> bool:
	if player_currency >= amount:
		print("CHA-CHING! -%d biomass, salary=%f" % [amount, salary])
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
	add_currency(salary*payment_frequency)

func increase_salary(amount: float):
	print("Increasing salary. %f --> %f" % [salary, salary+amount])
	salary += amount

func save_game():
	# TODO: Implement save system
	pass

func load_game():
	# TODO: Implement load system
	pass
	
func setup_salary_timer():
	var timer = Timer.new()
	timer.wait_time = payment_frequency
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_pay_salary)
	add_child(timer)
