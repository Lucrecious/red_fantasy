class_name Collision_Hitbox
extends Area2D

export(bool) var _use_self_as_body := false
export(Resource) var _initial_hit_data

onready var _body := self if _use_self_as_body else NodE.get_ancestor(self, CollisionObject2D) as CollisionObject2D
onready var _health := NodE.get_child(_body, Component_Health) as Component_Health
onready var _collision := NodE.get_child(self, CollisionShape2D) as CollisionShape2D

func _ready():
	assert(_body, 'must be present')
	assert(_collision, 'must be present')
	
	connect('body_entered', self, '_on_body_entered')
	
	set_hit_data(_initial_hit_data)

func flash() -> void:
	_collision.set_deferred('disabled', false)
	yield(get_tree(), 'physics_frame')
	yield(get_tree(), 'physics_frame')
	_collision.set_deferred('disabled', true)

func enable_sec(sec: float) -> void:
	_collision.set_deferred('disabled', false)
	
	yield(get_tree().create_timer(sec), 'timeout')
	
	_collision.set_deferred('disabled', true)

var _hit_data: Resource
func set_hit_data(data: Resource) -> void:
	_hit_data = data

func _on_body_entered(body: KinematicBody2D) -> void:
	if not _hit_data: return
	
	if _hit_data is Data_Damage:
		var damage_receiver := NodE.get_child(body, Component_DamageReceiver) as Component_DamageReceiver
		
		var dir := (body.global_position - global_position).normalized()
		
		if not damage_receiver: return
		
		damage_receiver.bleed_attack(_body, _hit_data)
	
