class_name AI_Controller
extends Node

onready var _body := NodE.get_ancestor(self, KinematicBody2D) as KinematicBody2D
onready var _virtual_input := NodE.get_child(NodE.get_child(_body, Component_Controller), Input_Virtual) as Input_Virtual

func _ready() -> void:
	assert(_body, 'must be set')
	assert(_virtual_input, 'must be set')

func press(actions: PoolStringArray, time_sec: float) -> void:
	for action in actions:
		_virtual_input.press(action)
	
	yield(get_tree().create_timer(time_sec), 'timeout')
	
	for action in actions:
		_virtual_input.release(action)
