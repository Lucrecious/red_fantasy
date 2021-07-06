extends Node2D

onready var _body := NodE.get_ancestor_with_error(self, KinematicBody2D) as KinematicBody2D
onready var _controller := NodE.get_sibling_with_error(self, Component_Controller) as Component_Controller
onready var _jump := NodE.get_sibling_with_error(self, Component_Jump) as Component_Jump
onready var _velocity := NodE.get_sibling_with_error(self, Component_Velocity) as Component_Velocity

func _ready() -> void:
	_controller.connect('action_just_pressed', self, '_on_action_just_pressed')

func _on_action_just_pressed(action: String) -> void:
	if not _body.is_on_floor(): return
	if _controller.direction.y <= 0: return
	if action != 'jump': return
	
	_velocity.y = 0
	_body.global_position.y += 5
	
	# This makes sure that the jump component skips the jump input... hopefully
	yield(get_tree(), 'idle_frame')
	_jump.enable()
	
