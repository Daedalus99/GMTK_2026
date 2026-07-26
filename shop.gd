extends Control

@export var wares: Array[Ware]  # Fallback wares if no stage is loaded.
@onready var ware_buttons_container: HBoxContainer = $Panel/HBoxContainer
@onready var shop_button = preload("uid://bylhcilxnv7bj")
@export var ware_spawn_container: Control

var bought_count = 0
var ware_purchase_counts: Dictionary = {}
@export var inflation_rate: float = 1.15

func _ready() -> void:
	GameManager.stage_changed.connect(_on_stage_changed)
	# Use the active stage's wares if already loaded, else fall back to export.
	if GameManager.current_stage:
		load_stage(GameManager.current_stage)
	else:
		_populate_wares(wares)

func _on_stage_changed(stage: Stage) -> void:
	load_stage(stage)

## Clears the shop and repopulates it from the given Stage resource.
func load_stage(stage: Stage) -> void:
	_populate_wares(stage.available_wares)

func _populate_wares(new_wares: Array[Ware]) -> void:
	# Clear existing buttons.
	for child in ware_buttons_container.get_children():
		child.queue_free()

	wares = new_wares
	bought_count = 0

	for ware in wares:
		if not ware_purchase_counts.has(ware.name):
			ware_purchase_counts[ware.name] = 0

		var new_button = shop_button.instantiate().get_child(0)
		update_button_text(new_button, ware)
		new_button.icon = ware.png
		ware_buttons_container.add_child(new_button.get_parent())
		new_button.pressed.connect(_purchase.bind(ware, new_button))

func get_current_cost(ware: Ware) -> int:
	var purchases = ware_purchase_counts[ware.name]
	return int(ware.cost * pow(inflation_rate, purchases))

func update_button_text(button: Button, ware: Ware):
	var current_cost = get_current_cost(ware)
	var owned = ware_purchase_counts[ware.name]
	(button.find_child("Name") as Label).text =  "%s [x%d]" % [ware.name, owned]
	(button.find_child("Price") as Label).text = str(current_cost)

func _purchase(ware: Ware, button: Button):
	var current_cost = get_current_cost(ware)
	if GameManager.spend_currency(current_cost):
		# Update purchase count and costs
		ware_purchase_counts[ware.name] += 1
		GameManager.increase_salary(ware.dps)
		bought_count += 1
		
		# Update button text with new cost and count
		update_button_text(button, ware)

		# Spawn visual representation
		if ware_spawn_container is SilhouetteFill:
			(ware_spawn_container as SilhouetteFill).spawn_icon(ware.png)  
		elif ware_spawn_container:
			var ware_instance := TextureRect.new()
			ware_instance.texture = ware.png
			ware_spawn_container.add_child(ware_instance)
		else:
			push_warning("shop.gd: no ware_spawn_container assigned.")
