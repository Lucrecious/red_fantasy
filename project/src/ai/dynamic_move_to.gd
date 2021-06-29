class_name AI_DynamicMoveTo
extends Node2D

signal caught_node()

onready var _body := NodE.get_ancestor(self, KinematicBody2D) as KinematicBody2D
onready var _move_to := NodE.get_sibling(self, AI_MoveTo) as AI_MoveTo

var _update_timer: Timer

func _ready():
	assert(_move_to, 'must be sibling')
	
	_update_timer = Timer.new()
	_update_timer.one_shot = false
	_update_timer.autostart = false
	_update_timer.connect('timeout', self, '_update_target_position')
	add_child(_update_timer)

var _target_node: Node2D
var _rect_range: ReferenceRect
func target(node: Node2D, rect: ReferenceRect, update_sec := 0.0) -> void:
	assert((node and rect) or (not node and not rect))
	if node == _target_node:
		_rect_range = rect
		if update_sec > 0:
			_update_timer.wait_time = update_sec
		return
	
	_update_timer.stop()
	
	if _target_node:
		_target_node.disconnect('tree_exiting', self, '_remove_target')
	
	_target_node = node
	_rect_range = rect
	
	if _target_node:
		_target_node.connect('tree_exiting', self, '_remove_target')
		_update_timer.start(update_sec)
		_update_target_position()

func stop() -> void:
	target(null, null)
	return

func _update_target_position() -> void:
	var pos := _get_target_pos(_target_node.global_position, _rect_range.get_rect())
	
	if _move_to.is_at_location(pos):
		target(null, null)
		emit_signal('caught_node')
		return
	
	_move_to.target(pos)

func _get_target_pos(center: Vector2, box_local: Rect2) -> Vector2:
	var target_position: Vector2
	
	var box_right := box_local
	box_right.position += _body.global_position
	
	var ranges := _get_ranges(center, box_right)
	var space := get_world_2d().direct_space_state
	
	var center_left := (ranges.left_right + (ranges.left_left - ranges.left_right) / 2.0) as float
	var center_right := (ranges.right_right + (ranges.right_left - ranges.right_right) / 2.0) as float
	var left_result := space.intersect_point(Vector2(center_left, center.y), 1, [_body])
	var right_result := space.intersect_point(Vector2(center_right, center.y), 1, [_body])
	
	if not left_result.empty() and left_result[0].collider.get_instance_id() < _body.get_instance_id():
		left_result.clear()
	
	if not right_result.empty() and right_result[0].collider.get_instance_id() < _body.get_instance_id():
		right_result.clear()
	
	var left_is_closer := abs(_body.global_position.x - center_left) < abs(_body.global_position.x - center_right)
	
	var left := false
	
	if (left_result.empty() and right_result.empty())\
	or (not left_result.empty() and not right_result.empty()):
		if left_is_closer:
			left = true
		else:
			left = false
	elif left_result.empty() and not right_result.empty():
		left = true
	elif not left_result.empty() and right_result.empty():
		left = false
	
	var box_left := box_local
	box_left.position *= -1
	box_left.size *= -1
	box_left = box_left.abs()
	box_left.position += _body.global_position
	
	if left and box_left.has_point(center):
		return center
	
	if not left and box_right.has_point(center):
		return center
	
	if left:
		return Vector2(center_left, center.y)
	
	return Vector2(center_right, center.y)

func _get_ranges(center: Vector2, box: Rect2) -> Dictionary:
	var ranges := {
		left_left = -INF,
		left_right = -INF,
		right_left = INF,
		right_right = INF,
	}
	
	var offset := box.position - _body.global_position
	ranges.left_left = center.x - box.size.x - abs(offset.x)
	ranges.left_right = center.x - abs(offset.x)
	ranges.right_left = center.x + abs(offset.x)
	ranges.right_right = center.x + box.size.x + abs(offset.x)
	
	return ranges

func _remove_target() -> void:
	target(null, null)




