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
@onready var sprite_container : TextureRect = $SilhouetteDisplay

## Velocity table keyed by child node instance id.
var _velocities: Dictionary = {}


func _ready() -> void:
	# Connect to sprite_container's signal so we catch icons added there by the shop.
	sprite_container.child_entered_tree.connect(_on_icon_added)
	# Register any children already in the scene (test sprites etc).
	for child in sprite_container.get_children():
		_on_icon_added(child)


func _process(delta: float) -> void:
	var bounds_size := sprite_container.size

	for child in sprite_container.get_children():
		if not child is Control:
			continue
		var id := child.get_instance_id()
		if not _velocities.has(id):
			continue

		var ctrl := child as Control
		var vel: Vector2 = _velocities[id]
		var new_pos := ctrl.position + vel * delta

		if new_pos.x < 0.0:
			new_pos.x = 0.0
			vel.x = absf(vel.x)
		elif new_pos.x + ctrl.size.x > bounds_size.x:
			new_pos.x = bounds_size.x - ctrl.size.x
			vel.x = -absf(vel.x)

		if new_pos.y < 0.0:
			new_pos.y = 0.0
			vel.y = absf(vel.y)
		elif new_pos.y + ctrl.size.y > bounds_size.y:
			new_pos.y = bounds_size.y - ctrl.size.y
			vel.y = -absf(vel.y)

		ctrl.position = new_pos
		_velocities[id] = vel


func _on_icon_added(child: Node) -> void:
	if not child is Control:
		return
	var ctrl := child as Control

	# Wait a frame so ctrl.size is valid before reading it.
	await get_tree().process_frame

	var bounds_size := sprite_container.size
	ctrl.position = Vector2(
		randf_range(0.0, maxf(0.0, bounds_size.x - ctrl.size.x)),
		randf_range(0.0, maxf(0.0, bounds_size.y - ctrl.size.y))
	)

	var angle := randf_range(0.0, TAU)
	var speed := randf_range(min_speed, max_speed)
	_velocities[ctrl.get_instance_id()] = Vector2(cos(angle), sin(angle)) * speed
