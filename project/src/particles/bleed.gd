extends CPUParticles2D

export(int) var _start := 2

onready var _body := NodE.get_ancestor_with_error(self, KinematicBody2D) as KinematicBody2D
onready var _health := NodE.get_child(_body, Component_Health) as Component_Health

func _ready():
	_health.connect('damaged', self, '_on_health_damaged')
	_on_health_damaged(0)

func _on_health_damaged(_amount: int) -> void:
	var current := _health.current
	if current == 0:
		emitting = false
	elif current < _start:
		emitting = true
	else:
		emitting = false
