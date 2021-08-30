extends Node2D

export(bool) var _no_reset := false

onready var _particles := $Partcles as CPUParticles2D
onready var _wall_collision := $Wall/Collision as CollisionShape2D
onready var _detect := $Detect as Area2D

func _ready() -> void:
	_wall_collision.set_deferred('disabled', true)
	_detect.connect('body_entered', self, '_on_body_entered')
	_particles.emitting = false

func _on_body_entered(body: PhysicsBody2D) -> void:
	var player := body as KinematicBody2D
	if not player:
		return
	
	_detect.disconnect('body_entered', self, '_on_body_entered')
	_wall_collision.set_deferred('disabled', false)
	_particles.emitting = true

func reset() -> void:
	if _no_reset:
		return
	
	_wall_collision.set_deferred('disabled', true)
	_particles.emitting = false
	ObjEct.connect_once(_detect, 'body_entered', self, '_on_body_entered')
	
