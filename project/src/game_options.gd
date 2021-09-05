extends Node

signal camera_shake_changed()
signal camera_smooth_changed()

var camera_shake := true setget _camera_shake_set
var camera_smooth := true setget _camera_smooth_set

func _camera_shake_set(value: bool) -> void:
	if camera_shake == value:
		return
	
	camera_shake = value
	emit_signal('camera_shake_changed')

func _camera_smooth_set(value: bool) -> void:
	if camera_smooth == value:
		return
	
	camera_smooth = value
	emit_signal('camera_smooth_changed')
