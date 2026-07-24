extends Control

@export var wares: Array[Ware]
@onready var ware_buttons_container: HBoxContainer = $Panel/HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for ware in wares:
		var new_button = Button.new()
		new_button.text = ware.name
		new_button.icon = ware.png
		ware_buttons_container.add_child(new_button)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
