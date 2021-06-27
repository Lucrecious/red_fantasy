class_name Component_Dodge
extends Node2D

signal dodge_started()
signal dodge_ended()

export(String) var _dodge_animation_name := ''
export(float) var _max_speed := 3.0
export(CurveTexture) var _speed_curve: CurveTexture = null
export(float) var _curve_sec := 1.0
export(NodePath) var _dodge_priority_node_path := NodePath()

onready var _disabler := NodE.get_sibling(self, Component_Disabler) as Component_Disabler
onready var _velocity := NodE.get_sibling(self, Component_Velocity) as Component_Velocity
onready var _controller := NodE.get_sibling(self, Component_Controller) as Component_Controller
onready var _animation_player := NodE.get_sibling(self, Component_PriorityAnimationPlayer) as Component_PriorityAnimationPlayer
onready var _dodge_priority_node := get_node_or_null(_dodge_priority_node_path) as PriorityNodePlaceholder

func _ready() -> void:
	set_physics_process(false)
	
	assert(_disabler, 'must be set')
	assert(_controller, 'must be set')
	assert(_velocity, 'must be set')
	assert(_animation_player, 'must be set')
	assert(_dodge_priority_node, 'must be set')
	
	_controller.connect('action_just_pressed', self, '_on_action_just_pressed')
	
	enable()

var _enabled := false
func enable() -> void:
	if _enabled: return
	_enabled = true

func disable() -> void:
	if not _enabled: return
	_enabled = false
	_callback_finish_dodge()

func _on_action_just_pressed(action: String) -> void:
	if not _enabled: return
	
	if _controller.direction.x == 0: return
	if action != 'dodge': return
	
	_dodge(sign(_controller.direction.x))

func is_dodging() -> bool:
	return _dodge_direction != -1

var _dodge_direction := 0
onready var _dodge_start_msec := 0
func _dodge(direction: int) -> void:
	if not _enabled: return
	if _dodge_direction != 0: return
	
	direction = direction if direction else 1
	_disabler.disable_below(self)
	_dodge_direction = direction
	_dodge_start_msec = OS.get_ticks_msec()
	set_physics_process(true)
	
	_animation_player.callback_on_finished(_dodge_animation_name, _dodge_priority_node, self, '_callback_finish_dodge')
	emit_signal('dodge_started')

func _callback_finish_dodge() -> void:
	if _enabled:
		_disabler.enable_below(self)
	
	set_physics_process(false)
	_dodge_direction = 0
	_velocity.value.x = 0
	
	emit_signal('dodge_ended')

func _physics_process(_delta: float) -> void:
	if not _enabled: return
	
	if _speed_curve:
		var percent := clamp((OS.get_ticks_msec() - _dodge_start_msec) / (1000.0 * _curve_sec), 0.0, 1.0)
		var amount := _speed_curve.curve.interpolate_baked(percent)
		_velocity.value.x = _max_speed * _dodge_direction * amount
	else:
		_velocity.value.x = _max_speed * _dodge_direction







