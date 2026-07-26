class_name Stage
extends Resource

@export var name: String = "new stage"
@export var metric_name: String = "Percent remaining"
@export_multiline var transition_message: String = ""
@export var starting_amount: float = 100_000_000
@export var available_wares: Array[Ware]
@export var currency_png: Texture2D
@export var stage_scene: PackedScene
@export var reset_salary_on_start: bool = true
