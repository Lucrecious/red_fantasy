extends Area2D

export(Resource) var hit_data: Resource = null

export(Array, Color) var _exposion_colors := []

onready var _body := NodE.get_ancestor_with_error(self, KinematicBody2D) as KinematicBody2D

func _ready():
	connect('body_entered', self, '_on_body_entered')

var _parried := false

func _on_body_entered(body: KinematicBody2D) -> void:
	if not hit_data: return
	
	var damage_receiver := NodE.get_child_with_error(body, Component_DamageReceiver) as Component_DamageReceiver
	var is_hit := damage_receiver.projectile(_body, hit_data)
	
	if not is_hit: return
	
	_body.queue_free()
	
	for c in _exposion_colors:
		ParticleInstancer.explode(_body, c)





