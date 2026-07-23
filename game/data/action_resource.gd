class_name ActionResource
extends Resource

@export var action_id: String
@export var display_name: String
@export var description: String

@export_group("Costs")
@export var base_purchase_cost: float = 100.0
@export var cost_scaling_factor: float = 1.5  # Cost multiplier per level

@export_group("Output")
@export var base_manual_reduction: float = 1.0
@export var base_auto_reduction_rate: float = 0.0  # Per second when automated
@export var output_scaling_factor: float = 1.2  # Output multiplier per level

@export_group("Behavior")
@export var cooldown_duration: float = 0.0  # Seconds between manual uses
@export var max_level: int = -1  # -1 means unlimited
@export var unlock_threshold: float = 0.0  # Progress threshold to unlock
@export var starts_unlocked: bool = false

# Calculate cost for purchasing the next level
func get_cost_for_level(current_level: int) -> float:
	if current_level == 0:
		return base_purchase_cost
	return base_purchase_cost * pow(cost_scaling_factor, current_level)

# Calculate manual output at given level
func get_manual_output_at_level(level: int) -> float:
	if level == 0:
		return 0.0
	return base_manual_reduction * pow(output_scaling_factor, level - 1)

# Calculate automated output per second at given level
func get_auto_output_at_level(level: int) -> float:
	if level == 0 or base_auto_reduction_rate == 0.0:
		return 0.0
	return base_auto_reduction_rate * pow(output_scaling_factor, level - 1)

# Check if action has unlimited levels
func has_unlimited_levels() -> bool:
	return max_level < 0

# Check if level is at maximum
func is_at_max_level(current_level: int) -> bool:
	return not has_unlimited_levels() and current_level >= max_level