extends Container

@onready var percent_label: Label = $objective_hp/amount
@onready var dps_label: Label = $dps

func _ready() -> void:
	# 1. Listen to the global signal whenever it fires
	GameManager.currency_changed.connect(_update_hp)
	GameManager.salary_changed.connect(_update_dps)
	
	# 2. Set the initial text to the current currency value
	_update_hp(GameManager.player_currency)
	_update_dps(0)

func _update_hp(amount: int) -> void:
	var percent = 100* (GameManager.curr_objective_hp / GameManager.base_objective_hp)
	percent_label.text = "%.1f%%" % percent

func _update_dps(total_dps: float) -> void:
	var percent_per_second = total_dps / GameManager.base_objective_hp
	var new_txt: String
	if percent_per_second < 0.01:
		new_txt = "%s%% per second" % Utils.sci_no(percent_per_second)
	elif percent_per_second < 10:
		new_txt = "%.2f%% per second" % percent_per_second
	else:
		new_txt = "%.1f%% per second" % percent_per_second
	# new_txt = "%f.1 = %s" % [total_dps, new_txt]
	dps_label.text = new_txt
