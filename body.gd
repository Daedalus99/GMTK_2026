## body.gd
## Body-stage specific behaviour.
## Attach to the Body Control node in Body.tscn.
## Extends ClickableTarget so left-clicks still add currency.
##
## Any Control children added at runtime (spawned by the shop) will
## automatically begin bouncing inside this node's rect.
class_name BodyStage
extends ClickableTarget

## Pixels per second for newly spawned icons.
@export var min_speed: float = 80.0
@export var max_speed: float = 220.0

## Velocity table keyed by child node instance id.
var _velocities: Dictionary = {}


func _ready() -> void:
	child_entered_tree.connect(_on_child_entered)


func _process(delta: float) -> void:
	var bounds := get_rect()  # Local rect: origin (0,0), size = self.size

	for child in get_children():
		if not child is Control:
			continue
		var id := child.get_instance_id()
		if not _velocities.has(id):
			continue

		var ctrl := child as Control
		var vel: Vector2 = _velocities[id]
		var new_pos := ctrl.position + vel * delta

		# Bounce off left/right walls.
		if new_pos.x < 0.0:
			new_pos.x = 0.0
			vel.x = absf(vel.x)
		elif new_pos.x + ctrl.size.x > bounds.size.x:
			new_pos.x = bounds.size.x - ctrl.size.x
			vel.x = -absf(vel.x)

		# Bounce off top/bottom walls.
		if new_pos.y < 0.0:
			new_pos.y = 0.0
			vel.y = absf(vel.y)
		elif new_pos.y + ctrl.size.y > bounds.size.y:
			new_pos.y = bounds.size.y - ctrl.size.y
			vel.y = -absf(vel.y)

		ctrl.position = new_pos
		_velocities[id] = vel


func _on_child_entered(child: Node) -> void:
	if not child is Control:
		return
	var ctrl := child as Control

	# Wait a frame so the child's size is finalised before placing it.
	await get_tree().process_frame

	var bounds := get_rect()
	var spawn_x := randf_range(0.0, maxf(0.0, bounds.size.x - ctrl.size.x))
	var spawn_y := randf_range(0.0, maxf(0.0, bounds.size.y - ctrl.size.y))
	ctrl.position = Vector2(spawn_x, spawn_y)

	# Random direction, random speed.
	var angle := randf_range(0.0, TAU)
	var speed := randf_range(min_speed, max_speed)
	_velocities[child.get_instance_id()] = Vector2(cos(angle), sin(angle)) * speed
