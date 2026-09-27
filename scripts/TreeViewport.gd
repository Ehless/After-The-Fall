extends Control
 
var mouse_is_down := false
var dragging := false
var press_start_mouse := Vector2.ZERO
var press_start_content_pos := Vector2.ZERO
 
const DRAG_THRESHOLD := 8.0  # pixels of movement before it counts as a drag, not a click
const ZOOM_STEP := 1.1
const MIN_ZOOM := 0.3
const MAX_ZOOM := 3.0
 
# Using _input instead of _gui_input: buttons "eat" clicks that land on them,
# so _gui_input never sees a press that started on top of a button.
# _input sees every raw mouse event first, before Godot decides which
# button gets it — so dragging works no matter where you start the click.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if get_global_rect().has_point(event.position):
				mouse_is_down = true
				dragging = false
				press_start_mouse = event.position
				press_start_content_pos = $TalentsContainer.position
		else:
			mouse_is_down = false
			dragging = false
	elif event is InputEventMouseMotion and mouse_is_down:
		var delta: Vector2 = event.position - press_start_mouse
		if not dragging and delta.length() > DRAG_THRESHOLD:
			dragging = true
		if dragging:
			$TalentsContainer.position = press_start_content_pos - delta
			_clamp_position()
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
		if get_global_rect().has_point(event.position):
			_zoom(ZOOM_STEP)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
		if get_global_rect().has_point(event.position):
			_zoom(1.0 / ZOOM_STEP)
 
# Pinch-to-zoom on touchscreens (Android, mobile browsers).
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMagnifyGesture:
		_zoom(event.factor)
 
func _zoom(factor: float) -> void:
	var new_scale: Vector2 = $TalentsContainer.scale * factor
	new_scale.x = clamp(new_scale.x, MIN_ZOOM, MAX_ZOOM)
	new_scale.y = clamp(new_scale.y, MIN_ZOOM, MAX_ZOOM)
	$TalentsContainer.scale = new_scale
	_clamp_position()
 
# TalentsContainer doesn't auto-resize to fit its buttons, so we work out
# the real bounding size of the tree by checking every button's edge.
# This goes recursively through sub-category groups too, not just direct children.
func _get_content_size() -> Vector2:
	return _get_bounds($TalentsContainer, Vector2.ZERO)
 
func _get_bounds(node: Node, offset: Vector2) -> Vector2:
	var max_extent := Vector2.ZERO
	for child in node.get_children():
		if child is Control:
			var child_offset: Vector2 = offset + child.position
			var extent: Vector2 = child_offset + child.size
			max_extent.x = max(max_extent.x, extent.x)
			max_extent.y = max(max_extent.y, extent.y)
			# Recurse in case this child is itself a category group with its own buttons
			var sub_extent: Vector2 = _get_bounds(child, child_offset)
			max_extent.x = max(max_extent.x, sub_extent.x)
			max_extent.y = max(max_extent.y, sub_extent.y)
	return max_extent
 
# Keeps the tree from being dragged/zoomed out of view.
# If the tree is smaller than the viewer, it just stays centered.
func _clamp_position() -> void:
	var content_size: Vector2 = _get_content_size() * $TalentsContainer.scale
	var pos: Vector2 = $TalentsContainer.position
 
	if content_size.x <= size.x:
		pos.x = (size.x - content_size.x) / 2.0
	else:
		pos.x = clamp(pos.x, size.x - content_size.x, 0.0)
 
	if content_size.y <= size.y:
		pos.y = (size.y - content_size.y) / 2.0
	else:
		pos.y = clamp(pos.y, size.y - content_size.y, 0.0)
 
	$TalentsContainer.position = pos
 
# Call this whenever the Talents screen is opened,
# so the tree always starts centered and un-zoomed.
func reset_view() -> void:
	$TalentsContainer.scale = Vector2.ONE
	$TalentsContainer.position = Vector2.ZERO
	_clamp_position()
