## SilhouetteFill
## Scatters purchased robocell icons randomly inside a human silhouette shape.
## Wire this node as the `ware_spawn_container` on your Shop node.
##
## Scene structure:
##   SilhouetteFill  (Control — manages layout and interior point cache)
##   ├── Silhouette  (TextureRect — human silhouette PNG, drawn on top as overlay)
##   └── [icons]     (spawned at runtime behind the Silhouette)
##
## True alpha-shape clipping is handled by sampling the silhouette texture
## during interior point generation — icons are only ever placed inside the shape.
## clip_contents = true clips the rectangular bounds.

@tool
class_name SilhouetteFill
extends ClickableTarget

## The silhouette texture defining the fill boundary (needs alpha channel).
@export var silhouette_texture: Texture2D:
	set(value):
		silhouette_texture = value
		_update_silhouette()

## Size of each spawned robocell sprite in pixels.
@export var cell_size: Vector2 = Vector2(32, 32)

## How many placement attempts per spawn before giving up.
@export var max_placement_attempts: int = 64

@onready var _silhouette_rect: TextureRect = $Silhouette

# Cache of pre-sampled valid interior positions, rebuilt when silhouette changes.
var _interior_points: PackedVector2Array = []
var _occupied: Array[Vector2] = []


func _ready() -> void:
	clip_contents = true
	resized.connect(_on_resized)
	_update_silhouette()
	_fit_silhouette()


func _on_resized() -> void:
	_fit_silhouette()
	_build_interior_cache()


## Fits the Silhouette rect centred and aspect-correct, rotated 90°.
## Because it's rotated, the texture's width maps to screen height and vice versa.
func _fit_silhouette() -> void:
	if not is_node_ready() or not _silhouette_rect:
		return
	var tex: Texture2D = silhouette_texture if silhouette_texture else _silhouette_rect.texture
	if not tex:
		return

	# Force free positioning — anchor layout_mode fights script-set position/size.
	_silhouette_rect.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)

	# Swap w/h because the texture is displayed rotated 90°.
	var tex_w := float(tex.get_height())
	var tex_h := float(tex.get_width())
	var scale_factor := minf(size.x / tex_w, size.y / tex_h)
	var fitted := Vector2(tex_w, tex_h) * scale_factor

	_silhouette_rect.size = fitted
	_silhouette_rect.pivot_offset = fitted / 2.0
	_silhouette_rect.rotation_degrees = 90.0
	# Centre within SilhouetteFill. pivot_offset is relative to the rect's
	# own space, so position accounts for it to land centred on screen.
	_silhouette_rect.position = (size - fitted) / 2.0


func _update_silhouette() -> void:
	if not is_node_ready():
		return
	if _silhouette_rect and silhouette_texture:
		_silhouette_rect.texture = silhouette_texture
	# The shader is on SilhouetteFill (self), not on the child rect.
	if material is ShaderMaterial:
		(material as ShaderMaterial).set_shader_parameter("silhouette", silhouette_texture)
	_build_interior_cache()


## Called by the shop when a ware is purchased.
## Spawns a TextureRect behind the Silhouette at a valid interior position.
func spawn_icon(texture: Texture2D) -> void:
	var pos := _find_valid_position()
	if pos == Vector2.INF:
		push_warning("SilhouetteFill: no valid position found after %d attempts." % max_placement_attempts)
		return

	var rect := TextureRect.new()
	rect.texture = texture
	rect.custom_minimum_size = cell_size
	rect.size = cell_size
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.position = pos - cell_size / 2.0
	# Add before the silhouette rect so icons appear behind it.
	add_child(rect)
	move_child(rect, 0)
	_occupied.append(pos)


# ------------------------------------------------------------------
# Internals
# ------------------------------------------------------------------

func _build_interior_cache() -> void:
	_interior_points.clear()
	_occupied.clear()

	if not silhouette_texture:
		return
	var img: Image = silhouette_texture.get_image()
	if not img:
		return

	img.decompress()
	var tex_size := img.get_size()

	# The silhouette rect is fitted and centred — map texture UVs into that space.
	var tex_w := float(tex_size.x)
	var tex_h := float(tex_size.y)
	var scale_factor: float = minf(size.x / tex_w, size.y / tex_h)
	var fitted := Vector2(tex_w, tex_h) * scale_factor
	var offset: Vector2 = (size - fitted) / 2.0

	var step := 4
	for y in range(0, int(tex_h), step):
		for x in range(0, int(tex_w), step):
			if img.get_pixel(x, y).a > 0.5:
				var local := Vector2(
					offset.x + (float(x) / tex_w) * fitted.x,
					offset.y + (float(y) / tex_h) * fitted.y
				)
				_interior_points.append(local)


func _find_valid_position() -> Vector2:
	if _interior_points.is_empty():
		_build_interior_cache()
	if _interior_points.is_empty():
		return Vector2.INF

	var min_dist := minf(cell_size.x, cell_size.y) * 0.8

	for _attempt in range(max_placement_attempts):
		var candidate: Vector2 = _interior_points[randi() % _interior_points.size()]
		var valid := true
		for occupied in _occupied:
			if candidate.distance_to(occupied) < min_dist:
				valid = false
				break
		if valid:
			return candidate

	return _interior_points[randi() % _interior_points.size()]
