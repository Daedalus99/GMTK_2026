## clickable_target.gd
## Generic script for any stage's main clickable object.
## Attach to the Control node the player clicks on.
## Override `click_power` per stage, or drive it from the active Stage resource.
class_name ClickableTarget
extends Control

@export var click_power: float = 1.0
# @export var target: Control

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_clicked()

func _on_clicked() -> void:
	GameManager.add_currency(click_power + (GameManager.salary*0.05))
