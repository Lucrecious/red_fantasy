class_name Component_DodgingTimesOverride
extends Node

export(Array, String) var _animations := []
export(Array, String) var _intervals := []

export(NodePath) var _dodge_path := NodePath()
export(NodePath) var _priority_node_path := NodePath()

var _animations_to_intervals := {}

onready var _animation_player := NodE.get_sibling_with_error(self, AnimationPlayer) as AnimationPlayer
onready var _dodge := NodE.get_node_with_error(self, _dodge_path, Component_Dodge) as Component_Dodge
onready var _controller := NodE.get_sibling_with_error(self, Component_Controller) as Component_Controller
onready var _disabler := NodE.get_sibling_with_error(self, Component_Disabler) as Component_Disabler
onready var _priority_node := NodE.get_node_with_error(self, _priority_node_path, PriorityNodePlaceholder) as PriorityNodePlaceholder

var _enabled := false
func enable() -> void:
	if _enabled: return
	_enabled = true

func disable() -> void:
	if not _enabled: return
	_enabled = false
	_finish_dodge_override()

func _ready():
	assert(_animations.size() == _intervals.size())
	
	for i in _animations.size():
		var intervals := _intervals[i].split_floats(',', false) as PoolRealArray
		_animations_to_intervals[_animations[i]] = intervals
	
	_controller.connect('action_just_pressed', self, '_on_action_just_pressed')
	
	enable()

func _on_action_just_pressed(action: String) -> void:
	if not _enabled: return
	
	if not _dodge.input_binding.is_pressed(_controller): return
	
	if not can_dodge(): return
	
	_disabler.disable_below(self)
	_dodge.enable()
	
	if not _dodge.dodge(_controller.direction.x, _priority_node): return
	
	if not _dodge.is_dodging():
		_disabler.enable_below(self)
		return
	
	
	yield(_dodge, 'dodge_ended')
	
	if not _enabled: return
	
	_finish_dodge_override()

func _finish_dodge_override() -> void:
	if _enabled:
		_disabler.enable_below(self)

func can_dodge() -> bool:
	if not _enabled: return false
	
	var animation := _animation_player.current_animation
	if not animation in _animations_to_intervals: return false
	
	var intervals := _animations_to_intervals.get(animation, []) as Array
	if intervals.empty(): return false
	
	var time_sec := _animation_player.current_animation_position
	
	for i in range(0, intervals.size(), 2):
		if time_sec < intervals[i] or time_sec > intervals[i + 1]: continue
		return true
	
	return false









