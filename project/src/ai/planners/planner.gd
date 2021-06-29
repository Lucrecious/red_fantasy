class_name Planner_Abstract
extends Node2D

onready var _body := get_parent() as KinematicBody2D
onready var _root_sprite := NodE.get_child(_body, Component_RootSprite) as Component_RootSprite
onready var _move_to := $MoveTo as AI_MoveTo
onready var _dynamic_move_to := $DynamicMoveTo as AI_DynamicMoveTo
onready var _actioner := $Actioner as AI_Actioner

onready var _chain := AI_Chain.new()

func _ready() -> void:
	assert(_body, 'must be parent')
	assert(_root_sprite, 'must exist')
	
	_chain = AI_Chain.new()
	add_child(_chain)
	_chain.connect('run_ended', self, '_on_run_ended')

func _on_run_ended() -> void:
	assert(false, 'must be implemented')




