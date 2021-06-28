class_name Component_Shield
extends Node2D

signal shielding_started()
signal blocking_started()
signal parry_started()
signal shielding_ended()

export(String) var _block_start := ''
export(String) var _parry := ''
export(NodePath) var _priority_node_path := NodePath()

onready var _priority_node := get_node_or_null(_priority_node_path) as Node
onready var _animation_player := NodE.get_sibling(self, Component_PriorityAnimationPlayer) as Component_PriorityAnimationPlayer
onready var _controller := NodE.get_sibling(self, Component_Controller) as Component_Controller
onready var _disabler := NodE.get_sibling(self, Component_Disabler) as Component_Disabler

var _shielding := false
var _blocking := false
var _parrying := false

func is_shielding() -> bool: return _shielding
func is_blocking() -> bool: return _blocking
func is_parrying() -> bool: return _parrying

var _enabled := false

func enable() -> void:
	if _enabled: return
	_enabled = true

func disable() -> void:
	if not _enabled: return
	_enabled = false
	
	_finish_shielding()

func _ready():
	assert(_priority_node, 'must be set')
	assert(_animation_player, 'must be sibling')
	assert(_controller, 'must be sibling')
	assert(_disabler, 'must be sibling')
	
	_controller.connect('action_just_pressed', self, '_on_action_just_pressed')
	_controller.connect('action_just_released', self, '_on_action_just_released')
	
	enable()

func _on_action_just_pressed(action: String) -> void:
	if not _enabled: return
	
	if _shielding or _blocking or _parrying: return
	if _controller.direction.x != 0: return
	if action != 'dodge': return
	
	_shielding = true
	_animation_player.callback_on_finished(_block_start, _priority_node, self, '_start_block_loop')
	_disabler.disable_below(self)
	emit_signal('shielding_started')

func _start_block_loop() -> void:
	if not _enabled: return
	
	_blocking = true
	emit_signal('blocking_started')

func _on_action_just_released(action: String) -> void:
	if not _enabled: return
	
	if not _shielding: return
	if action != 'dodge': return
	
	_shielding = false
	_blocking = false
	_parrying = true
	
	_animation_player.callback_on_finished(_parry, _priority_node, self, '_finish_shielding')
	
	emit_signal('parry_started')

func _finish_shielding() -> void:
	if _enabled:
		_disabler.enable_below(self)
	
	_shielding = false
	_blocking = false
	_parrying = false
	
	emit_signal('shielding_ended')




