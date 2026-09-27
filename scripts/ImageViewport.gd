extends Control
 
var dragging := false
var drag_start_mouse := Vector2.ZERO
var drag_start_image_pos := Vector2.ZERO
 
const ZOOM_STEP := 1.1
const MIN_ZOOM := 0.2
const MAX_ZOOM := 5.0
 
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			if dragging:
				drag_start_mouse = event.position
				drag_start_image_pos = $ImageDisplay.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom(ZOOM_STEP)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom(1.0 / ZOOM_STEP)
	elif event is InputEventMouseMotion and dragging:
		var delta: Vector2 = event.position - drag_start_mouse
		# Inverted: dragging right slides the *view* right, image moves left underneath.
		$ImageDisplay.position = drag_start_image_pos - delta
		_clamp_position()
 
func _zoom(factor: float) -> void:
	var new_scale: Vector2 = $ImageDisplay.scale * factor
	new_scale.x = clamp(new_scale.x, MIN_ZOOM, MAX_ZOOM)
	new_scale.y = clamp(new_scale.y, MIN_ZOOM, MAX_ZOOM)
	$ImageDisplay.scale = new_scale
	_clamp_position()
 
# Keeps the image from being dragged/zoomed out of view.
# If the image is smaller than the viewer, it just stays centered.
func _clamp_position() -> void:
	if $ImageDisplay.texture == null:
		return
 
	var image_size: Vector2 = $ImageDisplay.texture.get_size() * $ImageDisplay.scale
	var pos: Vector2 = $ImageDisplay.position
 
	if image_size.x <= size.x:
		pos.x = (size.x - image_size.x) / 2.0
	else:
		pos.x = clamp(pos.x, size.x - image_size.x, 0.0)
 
	if image_size.y <= size.y:
		pos.y = (size.y - image_size.y) / 2.0
	else:
		pos.y = clamp(pos.y, size.y - image_size.y, 0.0)
 
	$ImageDisplay.position = pos
 
# Pinch-to-zoom on touchscreens (Android, mobile browsers).
# This doesn't go through _gui_input like mouse events do.
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMagnifyGesture:
		_zoom(event.factor)
 
# Called from Talents.gd whenever a new image is loaded,
# so it always opens centered, un-zoomed, and within bounds.
func reset_view() -> void:
	$ImageDisplay.scale = Vector2.ONE
	if $ImageDisplay.texture != null:
		var image_size: Vector2 = $ImageDisplay.texture.get_size()
		# Center horizontally, but start at the top (y = 0) instead of centered,
		# so you begin reading from the top of the image, not the middle.
		$ImageDisplay.position = Vector2((size.x - image_size.x) / 2.0, 0.0)
	_clamp_position()
