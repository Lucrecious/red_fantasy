class_name Collision_Hitbox
extends Area2D

onready var _body := NodE.get_ancestor(self, KinematicBody2D) as KinematicBody2D
onready var _health := NodE.get_child(_body, Component_Health) as Component_Health
onready var _collision := NodE.get_child(self, CollisionShape2D) as CollisionShape2D

func _ready():
	assert(_body, 'must be present')
	assert(_collision, 'must be present')
	
	connect('body_entered', self, '_on_body_entered')

func flash() -> void:
	_collision.disabled = false
	yield(get_tree(), 'idle_frame')
	yield(get_tree(), 'idle_frame')
	_collision.disabled = true

func enable_sec(sec: float) -> void:
	_collision.disabled = false
	
	yield(get_tree().create_timer(sec), 'timeout')
	
	_collision.disabled = true

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
	
