class_name AI_Guard
extends Node2D

export(int, -1, 1, 2) var look_direction := -1


onready var _move_to := NodE.get_sibling_with_error(self, AI_MoveTo) as AI_MoveTo
onready var _body := NodE.get_ancestor_with_error(self, KinematicBody2D) as KinematicBody2D
onready var _input := NodE.get_child_with_error(NodE.get_child_with_error(_body, Component_Controller), Input_Virtual) as Input_Virtual

onready var location := _body.global_position as Vector2

func get_in_position(done_event: FuncREf) -> void:
	_move_to.target(location)
	
	yield(_move_to, 'arrived_at_target')
	
	if look_direction < 0:
		_input.flash_press('left_move')
	else:
		_input.flash_press('right_move')
	
	done_event.call_func()

func in_position() -> bool:
	return _move_to.is_at_location(location)
