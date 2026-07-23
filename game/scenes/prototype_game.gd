extends Node

# Scene configuration
@export var scenario_resource: ScenarioResource
@export var action_resources: Array[ActionResource]

# Game systems
var run_state: RunState
var action_manager: ActionManager
var game_ui: GameUI

func _ready() -> void:
	# Load default resources if not set in editor
	if not scenario_resource:
		scenario_resource = preload("res://game/resources/scenarios/sample_scenario.tres")
	
	if action_resources.is_empty():
		action_resources = [
			preload("res://game/resources/actions/basic_action.tres"),
			preload("res://game/resources/actions/auto_action.tres"),
			preload("res://game/resources/actions/advanced_action.tres")
		]
	
	# Create game systems
	run_state = RunState.new()
	action_manager = ActionManager.new()
	
	# Add to scene tree
	add_child(run_state)
	add_child(action_manager)
	
	# Initialize systems
	run_state.load_scenario(scenario_resource)
	action_manager.initialize(run_state, action_resources)
	
	# Set up UI
	game_ui = $GameUI as GameUI
	if game_ui:
		game_ui.setup(run_state, action_manager, scenario_resource, action_resources)
	else:
		push_error("GameUI node not found")

# Handle pause menu integration
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if run_state.run_status == RunState.Status.RUNNING:
			run_state.pause_run()
			get_tree().paused = true
		elif run_state.run_status == RunState.Status.PAUSED:
			run_state.resume_run()
			get_tree().paused = false