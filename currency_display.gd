# currency_ui.gd
extends Node

@onready var currency_label: Label = $Background/Dna/biomass_count

func _ready() -> void:
	# 1. Listen to the global signal whenever it fires
	GameManager.currency_changed.connect(_on_currency_updated)
	
	# 2. Set the initial text to the current currency value
	_update_display(GameManager.player_currency)

func _on_currency_updated(amount: int) -> void:
	# The signal passes the change (e.g. +10), but we want the new total
	_update_display(GameManager.player_currency)

func _update_display(total_currency: int) -> void:
	currency_label.text = "x" + str(floor(total_currency))
