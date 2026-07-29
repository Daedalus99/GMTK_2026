extends Container

@onready var progress_title: Label = $objective_hp/display_label
@onready var progress_label: Label = $objective_hp/amount
@onready var dps_label: Label = $dps
@onready var click_power: Label = $display_click/power
@onready var lore_container: Control = $"../LoreContainer"
var show_as_percent: bool = true  # default matches cell stage behaviour

func _ready() -> void:
	# 1. Listen to the global signal whenever it fires
	GameManager.currency_changed.connect(_update_hp)
	GameManager.salary_changed.connect(_update_dps)
	
	# 2. Set the initial text to the current currency value
	_update_hp(floor(GameManager.player_currency))
	_update_dps(0)
	
	#3. Set the progress title and formatting.
	var stage = GameManager.current_stage
	progress_title.text = "%s: " % stage.metric_name
	show_as_percent = stage.show_progress_as_percent
	_update_hp(GameManager.player_currency)

func _update_hp(_amount: float) -> void:
	var percent: float = 100.0 * (GameManager.curr_objective_hp / GameManager.base_objective_hp)
	if show_as_percent:
		progress_label.text = "%.1f%%" % percent
	else:
		progress_label.text = Utils.sci_no(GameManager.curr_objective_hp)
	var c: Color = lerp(Color.RED, Color.DARK_GREEN, percent / 100.0)
	progress_label.add_theme_color_override("font_outline_color", c)

func _update_dps(total_dps: float) -> void:
	var percent_per_second = total_dps / GameManager.base_objective_hp
	var new_txt: String
	if show_as_percent:
		if percent_per_second < 0.01:
			new_txt = "%s%% per second" % Utils.sci_no(percent_per_second)
		elif percent_per_second < 10:
			new_txt = "%.2f%% per second" % percent_per_second
		else:
			new_txt = "%.1f%% per second" % percent_per_second
	else:
		new_txt = ("%.1f" if total_dps < 10 else "%d") % total_dps
	# new_txt = "%f.1 = %s" % [total_dps, new_txt]
	dps_label.text = new_txt
	var p: float = GameManager.click_power
	click_power.text = ("%.1f" if p < 100 else "%d") % p 
	


func _on_lore_button_pressed() -> void:
	lore_container.hide()
