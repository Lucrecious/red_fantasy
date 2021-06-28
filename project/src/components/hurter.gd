class_name Component_Hurter
extends Node2D

onready var _health := NodE.get_sibling(self, Component_Health) as Component_Health

func _ready():
	assert(_health, 'must be sibling')
	
	_health.connect('damaged', self, '_bleed')

func _bleed(_amount: int) -> void:
	ParticleInstancer.blood(get_parent())
	ParticleInstancer.blood(get_parent())
