## CircleContainer
## A custom container that arranges visible child Control nodes evenly around
## the circumference of a circle, analogous to HBoxContainer / VBoxContainer.
##
## Properties:
##   radius          – distance from the container's centre to each child's anchor point
##   rotate_children – when true, each child is rotated so its local +Y axis points
##                     away from the circle centre (tangent orientation)
##
## Layout rules:
##   • Only visible children are positioned (hidden children are skipped).
##   • Items are spaced at equal angular intervals (360° / count).
##   • The FIRST item is always placed at the TOP of the circle (–Y, i.e. 270° in
##     standard math convention), ensuring vertical-axis symmetry regardless of
##     item count.
##   • The container's own size is set to a square that fits the circle
##     (2 * radius on each side).  Children are positioned relative to the
##     container's centre.

@tool
extends Container

@export_tool_button("Arrange Items") var arrange = _arrange_children

## Radius of the circle in pixels.
@export var radius: float = 100.0:
	set(value):
		radius = value
		queue_sort()

## When true, children are rotated so their local up-axis points away from centre.
@export var rotate_children: bool = false:
	set(value):
		rotate_children = value
		queue_sort()


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		_arrange_children()


func _arrange_children() -> void:
	# Collect only visible children that are Control nodes.
	var children: Array[Control] = []
	for child in get_children():
		if child is Control and child.visible:
			children.append(child as Control)

	var count := children.size()
	if count == 0:
		return

	# Set minimum size so the parent layout knows how much space we need.
	var diameter := radius * 2.0
	custom_minimum_size = Vector2(diameter, diameter)

	# Keep pivot at the centre so scaling/rotating this node feels natural,
	# and so that growing the radius expands outward from the middle.
	pivot_offset = size / 2.0

	var centre := size / 2.0
	var angle_step := TAU / float(count)

	# Start at –PI/2 so the first item lands at the top (12-o'clock position).
	var start_angle := -PI / 2.0

	for i in count:
		var child := children[i]
		var angle := start_angle + angle_step * float(i)

		# Position: circle point offset so the child is centred on that point.
		var child_size := child.size
		var point := centre + Vector2(cos(angle), sin(angle)) * radius
		fit_child_in_rect(child, Rect2(point - child_size / 2.0, child_size))

		# Optional rotation: align local +Y outward from centre.
		if rotate_children:
			child.pivot_offset = child_size / 2.0
			# angle already points outward; add PI/2 so +Y faces outward.
			child.rotation = angle + PI / 2.0
		else:
			child.pivot_offset = child_size / 2.0
			child.rotation = 0.0
