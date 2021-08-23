extends Node2D

export(NodePath) var _main_focus_path := NodePath()
export(Vector2) var _threshold_extents := Vector2.ZERO
export(Vector2) var _max_view_extents := Vector2.ZERO
export(Vector2) var _mild_shake_variance := Vector2.ZERO
export(float) var _min_trauma := 0.1

onready var _camera := get_parent() as Camera_Game
onready var _main_focus := get_node_or_null(_main_focus_path) as Node2D

export(OpenSimplexNoise) var _smooth_noise: OpenSimplexNoise = null
var _time_passed_msec := 0

var _focus_area: Area2D = null

func _enter_tree() -> void:
	_focus_area = preload('res://src/camera/focus_area.tscn').instance() as Area2D

func _exit_tree() -> void:
	if not _focus_area: return
	_focus_area.queue_free()

onready var _tween := Tween.new()

func _ready() -> void:
	assert(_camera, 'must be parent')
	assert(_main_focus, 'must be set')
	assert(_camera.get_parent() == _main_focus.get_parent(), 'camera and focus must have the same parent')
	assert(_camera.get_index() > _main_focus.get_index(), 'camera must be below main focus in scene tree')
	
	_main_focus.add_child(_focus_area)
	_main_focus.move_child(_focus_area, 0)
	_focus_area.global_position = _main_focus.global_position
	
	add_child(_tween)
	
	yield(_camera, 'ready')
	
	_focus_area.connect('area_entered', self, '_on_area_entered')
	_focus_area.connect('area_exited', self, '_on_area_exited')
	
	if not _smooth_noise:
		_smooth_noise = OpenSimplexNoise.new()
	
	randomize()
	_smooth_noise.seed = randi()

var _current_area: Area2D = null
var _margins := Rect2(-1e8, -1e8, 2e8, 2e8)
func _on_area_entered(area: Area2D) -> void:
	var previous_area := _current_area
	_current_area = area
	var rect := _get_rect_from_area(area)
	assert(rect.size.length_squared() > 0, 'must return rectangle with size')
	
	_tween.stop_all()
	_tween.remove_all()
	
	_margins = _camera.view_rect()
	
	var pixels_per_second := 2000.0
	
	var position_sec := (_margins.position - rect.position).length() / pixels_per_second
	var size_sec := max((_margins.size - rect.size).length() / pixels_per_second, .1)
	
	_tween.interpolate_property(self, '_margins:position:x', _margins.position.x, rect.position.x, position_sec, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	_tween.interpolate_property(self, '_margins:position:y', _margins.position.y, rect.position.y, position_sec, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	_tween.interpolate_property(self, '_margins:size:x', _margins.size.x, rect.size.x, size_sec, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	_tween.interpolate_property(self, '_margins:size:y', _margins.size.y, rect.size.y, size_sec, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	_tween.start()

func _on_area_exited(area: Area2D) -> void:
	if _current_area != area: return
	
	var overlapping_areas := _focus_area.get_overlapping_areas()
	overlapping_areas.erase(_current_area)
	if overlapping_areas.empty():
		_current_area = null
		_margins = Rect2(-1e8, -1e8, 2e8, 2e8)
		return
	
	_on_area_entered(overlapping_areas[0])

func _get_rect_from_area(area: Area2D) -> Rect2:
	if not area: return Rect2()
	
	var collision := NodE.get_child(area, CollisionShape2D) as CollisionShape2D
	if not collision: return Rect2()
	
	var rect_resource := collision.shape as RectangleShape2D
	if not rect_resource:
		assert(false, 'camera boxes must be rectangles')
		return Rect2()
	
	var rect := Rect2(collision.global_position - rect_resource.extents, rect_resource.extents * 2.0)
	return rect

func _physics_process(delta: float) -> void:
	_shake(delta)
	
	var smoothed_position := _smoothing()
	
	var offset := _get_margin_offset()
	
	var interpolated_position := smoothed_position + offset
	
	_camera.global_position = interpolated_position

func _get_margin_offset() -> Vector2:
	var view := _camera.view_rect()
	
	var area := _current_area as CameraBox_Game
	
	var view_tl := view.position
	var view_br := view_tl + view.size
	
	var margins_tl := _margins.position
	var margins_br := margins_tl + _margins.size
	
	var margined_position := _camera.global_position
	
	if view_tl.x < margins_tl.x and not (area and area.open_sides & area.Side.Left):
		margined_position.x += margins_tl.x - view_tl.x
	
	if view_br.x > margins_br.x and not (area and area.open_sides & area.Side.Right):
		margined_position.x += margins_br.x - view_br.x
	
	if view_tl.y < margins_tl.y and not (area and area.open_sides & area.Side.Top):
		margined_position.y += margins_tl.y - view_tl.y
	
	if view_br.y > margins_br.y and not (area and area.open_sides & area.Side.Bottom):
		margined_position.y += margins_br.y - view_br.y
	
	var offset := margined_position - _camera.global_position
	return offset

func _shake(delta: float) -> void:
	_camera.offset.x = _smooth_noise.get_noise_2d(_time_passed_msec * _min_trauma, 0) * _mild_shake_variance.x
	_camera.offset.y = _smooth_noise.get_noise_2d(0, _time_passed_msec * _min_trauma) * _mild_shake_variance.y
	
	_time_passed_msec += round(delta * 1000.0)

func _smoothing() -> Vector2:
	var threshold_rect := _get_threshold_rect()
	
	if threshold_rect.has_point(_main_focus.global_position): return _camera.global_position
	
	var pos := _main_focus.global_position
	
	var box_point := Vector2.INF
	box_point = Math.get_closest_point_on_rect(threshold_rect, _main_focus.global_position)
	var delta := _main_focus.global_position - box_point
	var target_position := _camera.global_position + delta
	
	_camera.global_position.x = lerp(_camera.global_position.x, target_position.x, 0.2)
	_camera.global_position.y = lerp(_camera.global_position.y, target_position.y, 0.1)
	
	var max_view_rect := _get_max_view_rect()
	if max_view_rect.has_point(pos): return _camera.global_position
	
	box_point = Math.get_closest_point_on_rect(max_view_rect, _main_focus.global_position)
	delta = _main_focus.global_position - box_point
	target_position = _camera.global_position + delta
	
	return target_position

func _get_threshold_rect() -> Rect2:
	var rect := Rect2(Vector2.ZERO - _threshold_extents, _threshold_extents * 2.0)
	rect.position += _camera.global_position - _camera.offset
	return rect

func _get_max_view_rect() -> Rect2:
	var rect := Rect2(Vector2.ZERO - _max_view_extents, _max_view_extents * 2.0)
	rect.position += _camera.global_position - _camera.offset
	return rect

func _draw() -> void:
	var rect := _get_threshold_rect()
	rect.position = to_local(rect.position)
	
	var rect2 := _get_max_view_rect()
	rect2.position = to_local(rect2.position)
	
	draw_rect(rect, Color.darkred, false, 2.0, false)
	draw_rect(rect2, Color.darkblue, false, 2.0, false)







