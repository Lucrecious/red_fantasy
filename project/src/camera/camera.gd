tool
class_name Camera_Game
extends Node2D

export(Vector2) var offset := Vector2.ZERO setget _offset_set

func _ready() -> void:
	if Engine.editor_hint: return
	
	set_notify_transform(true)

func _notification(what: int) -> void:
	if Engine.editor_hint: return
	
	if what != NOTIFICATION_TRANSFORM_CHANGED: return
	_update_viewport_transform()

func _draw() -> void:
	var rect := get_viewport_rect()
	rect.position -= rect.size / 2.0
	rect.position += offset
	draw_rect(rect, Color.black, false, 2.0, false)

func _update_viewport_transform() -> void:
	var ct := get_viewport().canvas_transform
	get_viewport().canvas_transform.origin = -global_transform.origin + get_viewport_rect().size / 2.0 - offset

func view_rect() -> Rect2:
	var rect := get_viewport_rect()
	rect.position -= rect.size / 2.0
	rect.position += offset
	rect.position += global_position
	return rect

func _offset_set(value: Vector2) -> void:
	offset = value
	update()




