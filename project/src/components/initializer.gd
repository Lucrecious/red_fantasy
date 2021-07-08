class_name Component_Initializer
extends Node


export(String, 'right', 'left') var _direction := 'right'
export(bool) var _use_custom_health := false
export(int, 0, 1000) var _custom_health := 1

onready var _body := NodE.get_ancestor_with_error(self, KinematicBody2D) as KinematicBody2D
onready var _turner := NodE.get_sibling_with_error(self, Component_Turner) as Component_Turner
onready var _health := NodE.get_sibling_with_error(self, Component_Health) as Component_Health
onready var _velocity := NodE.get_sibling_with_error(self, Component_Velocity) as Component_Velocity

onready var spawn_position :=_body.global_position

onready var _init_health := _health.current if not _use_custom_health else _custom_health

func _init().() -> void:
	add_to_group('initializer')

func _ready() -> void:
	_do_init()

func reinit() -> void:
	_do_init()

func _do_init() -> void:
	_body.global_position = spawn_position
	
	_velocity.value = Vector2.ZERO
	
	_health.current_set(_init_health, _body)
	
	match _direction:
		'left':
			_turner.direction = -1
		'right':
			_turner.direction = 1
		_: assert(false, 'one or the other')



