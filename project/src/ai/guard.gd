class_name AI_Guard
extends Node2D


onready var _move_to := NodE.get_sibling_with_error(self, AI_MoveTo) as AI_MoveTo
onready var _body := NodE.get_ancestor_with_error(self, KinematicBody2D) as KinematicBody2D
onready var _input := NodE.get_child_with_error(NodE.get_child_with_error(_body, Component_Controller), Input_Virtual) as Input_Virtual
onready var _turner := NodE.get_child_with_error(_body, Component_Turner) as Component_Turner

onready var look_direction := _turner.direction
onready var location := _body.global_position as Vector2

func get_in_position(done_event: FuncREf) -> void:
	if _move_to.is_at_location(location):
		done_event.call_func()
		return
	
	_move_to.target(location)
	
	ObjEct.disconnect_once(_move_to, 'arrived_at_target', self, '_pick_direction_and_call_done')
	_move_to.connect('arrived_at_target', self, '_pick_direction_and_call_done', [done_event], CONNECT_ONESHOT)

func _pick_direction_and_call_done(done_event: FuncREf) -> void:
	if look_direction < 0:
		_input.flash_press('left_move')
	else:
		_input.flash_press('right_move')
	
	done_event.call_func()

func in_position() -> bool:
	return _move_to.is_at_location(location)
