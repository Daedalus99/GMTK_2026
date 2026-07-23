class_name ScenarioResource
extends Resource

@export var scenario_id: String
@export var display_name: String
@export var description: String
@export var starting_target: float
@export var has_timer: bool = true
@export var run_duration: float = 600.0  # 10 minutes in seconds
@export var progress_thresholds: Array[float] = []  # Ordered thresholds for unlocks
@export var metadata: Dictionary = {}  # Optional presentation data