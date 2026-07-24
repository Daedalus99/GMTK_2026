extends Node

# Game state variables
var player_currency = 0
var level = 1
var cells_harvested = 0
var upgrades = {}

# Signals for UI updates
signal currency_changed(new_amount)
signal level_up(new_level)

func _ready():
	print("GameManager ready!")
	# Initialize game state
	reset_game()

func reset_game():
	player_currency = 0
	level = 1
	upgrades = {}
	currency_changed.emit(player_currency)

func add_currency(amount: int):
	player_currency += amount
	currency_changed.emit(player_currency)
	check_level_up()
	print("currency: ", player_currency)

func spend_currency(amount: int) -> bool:
	if player_currency >= amount:
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

func get_currency() -> int:
	return player_currency

func save_game():
	# TODO: Implement save system
	pass

func load_game():
	# TODO: Implement load system
	pass
