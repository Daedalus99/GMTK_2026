extends Node

# Game state variables
var player_biomass = 0
var level = 1
var cells_harvested = 0
var upgrades = {}

# Signals for UI updates
signal biomass_changed(new_amount)
signal level_up(new_level)

func _ready():
	print("GameManager ready!")
	# Initialize game state
	reset_game()

func reset_game():
	player_biomass = 100
	level = 1
	cells_harvested = 0
	upgrades = {}
	biomass_changed.emit(player_biomass)

func add_biomass(amount: int):
	player_biomass += amount
	cells_harvested += 1
	biomass_changed.emit(player_biomass)
	check_level_up()
	print("Biomass: ", player_biomass)

func spend_biomass(amount: int) -> bool:
	if player_biomass >= amount:
		player_biomass -= amount
		biomass_changed.emit(player_biomass)
		return true
	return false

func check_level_up():
	var required_biomass = level * 500  # Adjust as needed
	if player_biomass >= required_biomass:
		level += 1
		level_up.emit(level)
		print("Level up! Now level ", level)

func get_biomass() -> int:
	return player_biomass

func save_game():
	# TODO: Implement save system
	pass

func load_game():
	# TODO: Implement load system
	pass
