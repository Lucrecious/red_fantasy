extends Node2D

onready var _particles := $Particles as CPUParticles2D
onready var _ground := $Static/Collision as CollisionShape2D

func _ready() -> void:
	reset()

func open() -> void:
	_particles.emitting = false
	_ground.set_deferred('disabled', true)

func reset() -> void:
	_particles.emitting = true
	_ground.set_deferred('disabled', false)
