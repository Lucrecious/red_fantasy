class_name Component_AttackCombo
extends Node2D

signal combo_started(animation)
signal combo_finished()

export(Resource) var _input_binding: Resource = null
export(PoolStringArray) var _attack_combo := PoolStringArray()
export(NodePath) var _priority_node_path := NodePath()
export(PoolRealArray) var _animation_ends := PoolRealArray()
export(float) var _lower_gravtiy_factor := .2
export(bool) var _allow_jump_cancel := true

onready var _animation_player := NodE.get_sibling(self, Component_PriorityAnimationPlayer) as Component_PriorityAnimationPlayer
onready var _disabler := NodE.get_sibling(self, Component_Disabler) as Component_Disabler
onready var _velocity := NodE.get_sibling(self, Component_Velocity) as Component_Velocity
onready var _controller := NodE.get_sibling(self, Component_Controller) as Component_Controller
onready var _gravity := NodE.get_sibling(self, Component_Gravity) as Component_Gravity
onready var _jump := NodE.get_sibling(self, Component_Jump) as Component_Jump

onready var _priority_node := get_node_or_null(_priority_node_path) as PriorityNodePlaceholder

var _enabled := false

func enable() -> void:
	if _enabled: return
	_enabled = true

func disable() -> void:
	if not _enabled: return
	_enabled = false
	_finish_attack()

func _ready() -> void:
	assert(_input_binding is Input_ActionBinding, 'must be set')
	assert(_animation_player, 'must be sibling')
	assert(_disabler, 'must be sibling')
	assert(_velocity, 'must be sibling')
	assert(_controller, 'must be sibling')
	assert(_gravity, 'must be sibling')
	assert(_priority_node, 'must be set')
	
	assert(_attack_combo.size() == _animation_ends.size(), 'must be same size')
	
	_controller.connect('action_just_pressed', self, '_on_action_just_pressed')
	enable()

func _cancel_attack() -> void:
	_disabler.disable_below(get_parent().get_child(get_index() + 1))
	_disabler.enable_below(get_parent().get_child(_jump.get_index() + 1))

var _combo_count := 0
var _msec_since_last_attack := 0
var _combo_next := false
func _on_action_just_pressed(_action: String) -> void:
	if not _enabled:
		return
	
	if _allow_jump_cancel and _jump and _jump._can_jump() and is_attacking() and _action == 'jump':
		_disabler.disable_below(self)
		disable()
		_disabler.enable_below(self)
		enable()
		_jump.impulse()
		_animation_player.reset_and_stop()
		_animation_player.play_default()
		_animation_player.seek(_animation_player.current_animation_position, true)

	if not _input_binding.is_pressed(_controller):
		return
	
	attack()

func attack() -> void:
	if _attack_combo.empty(): return
	if _combo_next: return
	
	if _combo_count == 0:
		_start_attack()
		var animation := _attack_combo[_combo_count]
		var success := _animation_player.callback_on_finished(animation, _priority_node, self, '_finish_attack')
		if not success: return
		emit_signal('combo_started', animation)
	
	if _combo_count > 0 and _combo_count < _attack_combo.size():
		var msec_elapsed := OS.get_ticks_msec() - _msec_since_last_attack
		var animation_end_msec := int(_animation_ends[_combo_count - 1] * 1000.0)
		_combo_next = true
		
		if msec_elapsed < animation_end_msec:
			yield(get_tree().create_timer((animation_end_msec - msec_elapsed) / 1000.0), 'timeout')
			if not _enabled: return
		
		var animation := _attack_combo[_combo_count]
		var success := _animation_player.callback_on_finished(animation, _priority_node, self, '_finish_attack')
		if not success: return
		emit_signal('combo_started', animation)
		
		
	_combo_next = false
	_msec_since_last_attack = OS.get_ticks_msec()
	_combo_count += 1

func is_attacking() -> bool: return _attacking

var _attacking := false
func _start_attack() -> void:
	if not _enabled: return
	
	_attacking = true
	
	_velocity.value = Vector2.ZERO
	_disabler.disable_below(self)
	_gravity.add_filter(get_parent().get_path_to(self), self, '_reduce_gravity')

func _finish_attack() -> void:
	if _enabled and _combo_next: return
	
	if not _enabled: _combo_next = false
	
	_attacking = false
	_combo_count = 0
	_gravity.remove_filter(get_parent().get_path_to(self))
	
	if _enabled:
		_disabler.enable_below(self)
	
	emit_signal('combo_finished')

func _reduce_gravity(value: float) -> float:
	return value * _lower_gravtiy_factor













