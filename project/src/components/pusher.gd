class_name Component_Pusher
extends Node2D

export(float) var x := 0.0 setget _x_set, _x_get

onready var _velocity := NodE.get_sibling(self, Component_Velocity) as Component_Velocity
onready var _turner := NodE.get_sibling(self, Component_Turner) as Component_Turner

func _ready() -> void:
	assert(_velocity, 'must be sibling')
	assert(_turner, 'must be sibling')

func _x_set(value: float) -> void:
	if not _velocity: return
	if not _turner: return
	if _velocity.value.x == value: return
	
	_velocity.value.x = value * _turner.direction

func _x_get() -> float:
	if not _velocity: return 0.0
	return _velocity.value.x
