class_name AI_MoveTo
extends Node2D

const distance_threshold_pixels := 6.0

signal arrived_at_target()

var _moving := false
var _target: Vector2

onready var _body := NodE.get_ancestor(self, KinematicBody2D) as KinematicBody2D
onready var _controller := NodE.get_child(_body, Component_Controller) as Component_Controller
onready var _input := NodE.get_child(_controller, Input_Virtual) as Input_Virtual

func _ready() -> void:
	assert(_body, 'must be ancestor')
	assert(_controller, 'must exist')
	assert(_input, 'must have virtual input')
	
	set_physics_process(false)

func target(location: Vector2) -> void:
	_target = location
	
	var delta := (_target - _body.global_position)
	_move(sign(delta.x))
	
	if _moving: return
	
	_moving = true
	set_physics_process(true)

func stop() -> void:
	if not _moving: return
	_moving = false
	set_physics_process(false)
	_input.release('left_move')
	_input.release('right_move')
	emit_signal('arrived_at_target')

func _physics_process(_delta: float) -> void:
	if is_at_location(_target):
		stop()
		return

func _stop_moving() -> void:
	_input.release('left_move')
	_input.release('right_move')

func _move(direction: int) -> void:
	assert(abs(direction) == 1, 'must be 1 or -1')
	if direction > 0:
		_input.release('left_move')
		_input.press('right_move')
		return
	
	if direction < 0:
		_input.press('left_move')
		_input.release('right_move')
		return

func is_at_location(value: Vector2) -> bool:
	return abs(_body.global_position.x - value.x) < distance_threshold_pixels




