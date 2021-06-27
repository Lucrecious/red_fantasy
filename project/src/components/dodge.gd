class_name Component_Dodge
extends Node2D

signal dodge_started()
signal dodge_ended()

export(float) var _max_speed := 3.0
export(CurveTexture) var _speed_curve: CurveTexture = null
export(float) var _curve_sec := 1.0

onready var _disabler := NodE.get_sibling(self, Component_Disabler) as Component_Disabler
onready var _velocity := NodE.get_sibling(self, Component_Velocity) as Component_Velocity
onready var _controller := NodE.get_sibling(self, Component_Controller) as Component_Controller

func _ready() -> void:
	set_physics_process(false)
	
	assert(_disabler, 'must be set')
	assert(_controller, 'must be set')
	assert(_velocity, 'must be set')
	
	_controller.connect('action_just_pressed', self, '_on_action_just_pressed')

func _on_action_just_pressed(action: String) -> void:
	if _controller.direction.x == 0: return
	if action != 'dodge': return
	
	_dodge(sign(_controller.direction.x))

var _dodge_direction := 0
onready var _dodge_start_msec := 0
func _dodge(direction: int) -> void:
	direction = direction if direction else 1
	_disabler.disable_below(self)
	_dodge_direction = direction
	_dodge_start_msec = OS.get_ticks_msec()
	set_physics_process(true)
	
	emit_signal('dodge_started')

func _callback_finish_dodge() -> void:
	set_physics_process(false)
	_disabler.enable_below(self)
	_dodge_direction = 0
	_velocity.value.x = 0
	emit_signal('dodge_ended')

func _physics_process(_delta: float) -> void:
	if _speed_curve:
		var percent := clamp((OS.get_ticks_msec() - _dodge_start_msec) / (1000.0 * _curve_sec), 0.0, 1.0)
		var amount := _speed_curve.curve.interpolate_baked(percent)
		_velocity.value.x = _max_speed * _dodge_direction * amount
	else:
		_velocity.value.x = _max_speed * _dodge_direction







