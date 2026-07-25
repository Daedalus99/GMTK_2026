extends Control

@export var wares: Array[Ware]
@onready var ware_buttons_container: HBoxContainer = $Panel/HBoxContainer
@onready var shop_button = preload("uid://bylhcilxnv7bj")
@export var ware_spawn_container: Container

var bought_count = 0
var ware_purchase_counts = {}  # Track purchases per ware type
@export var inflation_rate = 1.15  # 15% cost increase per purchase
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for ware in wares:
		# Initialize purchase count
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
		if ware.scene or true:
			# var ware_instance = ware.scene.instantiate() as Node2D
			var ware_instance = TextureRect.new()
			ware_instance.texture = ware.png
			if ware_spawn_container:
				ware_spawn_container.add_child(ware_instance)
			else:
				ware_instance.position = bought_count * Vector2(10, 10)
				add_sibling(ware_instance)
				print("spawned sprite at %s, cost was %d" % [ware_instance.position, current_cost])
		else:
			print("NO SCENE ASSOCIATED WITH THIS ITEM")
