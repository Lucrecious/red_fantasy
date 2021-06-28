extends Node2D

onready var _body := get_parent() as KinematicBody2D
onready var _root_sprite := NodE.get_child(_body, Component_RootSprite) as Component_RootSprite
onready var _move_to := $MoveTo as AI_MoveTo
onready var _dynamic_move_to := $DynamicMoveTo as AI_DynamicMoveTo
onready var _actioner := $Actioner as AI_Actioner

onready var _awareness := NodE.get_child(self, AI_Awareness) as AI_Awareness

func _ready() -> void:
	assert(_body, 'must be parent')
	assert(_root_sprite, 'must exist')
	
	var player := get_tree().get_nodes_in_group('player')[0] as Node2D
	
	_awareness.connect('target_changed', self, '_on_target_changed')

var _chain: AI_Chain
func _on_target_changed() -> void:
	if _chain:
		_chain.queue_free()
		_chain = null
	
	if not _awareness.target():
		return
	
	_chain = AI_Chain.new()
	add_child(_chain)
	_chain.add(_dynamic_move_to, 'target', [_awareness.target(), $PunchRect, .2], 'caught_node')
	_chain.add(_actioner, 'attack_combo_by_name', ['Punch', _awareness.target()], 'finished')
	_chain.run()
	
