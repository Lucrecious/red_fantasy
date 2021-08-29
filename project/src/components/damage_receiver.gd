class_name Component_DamageReceiver
extends Node

signal damage_blocked()
signal attack_parried()
signal damage_received(damage)

export(int, LAYERS_2D_PHYSICS) var _parry_collision := 0

onready var _body := NodE.get_ancestor_with_error(self, KinematicBody2D) as KinematicBody2D
onready var _health := NodE.get_sibling_with_error(self, Component_Health) as Component_Health
onready var _dodge := NodE.get_sibling(self, Component_Dodge) as Component_Dodge
onready var _shield := NodE.get_sibling(self, Component_Shield) as Component_Shield
onready var _turner := NodE.get_sibling(self, Component_Turner) as Component_Turner

# Returns if it hit
func projectile(sender: Node2D, hit_data: Data_Damage) -> bool:
	if _is_parrying(sender):
		var velocity := NodE.get_child_with_error(sender, Component_Velocity) as Component_Velocity
		velocity.x = abs(velocity.x) * _turner.direction
		
		var hitbox := NodE.get_child(sender, load('res://src/components/projectile_hitbox.gd')) as Area2D
		if hitbox:
			hitbox.collision_mask = _parry_collision
		
		emit_signal('attack_parried')
		return false
	
	if _dodge and _dodge.is_immune(): return false
	
	var dir := _body.global_position - sender.global_position
	dir.y = -abs(dir.y)
	_do_knockback(hit_data, sign(dir.x))
	
	if not _is_blocking(sender):
		_do_damage(hit_data.damage, sender, dir)
	else:
		emit_signal('damage_blocked')
	
	return true

func bleed_attack(sender: Node2D, hit_data: Data_Damage) -> void:
	if _is_parrying(sender):
		var damage_receiver := NodE.get_child(sender, get_script())
		if not damage_receiver: return
		
		damage_receiver.bleed_attack(_body, hit_data)
		emit_signal('attack_parried')
		return
	
	var dir := _body.global_position - sender.global_position
	dir.y = -abs(dir.y)
	
	var is_dodge_immune := _dodge and _dodge.is_immune()
	var is_blocking := _is_blocking(sender)
	
	if is_dodge_immune or is_blocking:
		if is_blocking:
			emit_signal('damage_blocked')
	else:
		_do_damage(hit_data.damage, sender, dir)
	
	if not is_dodge_immune:
		_do_knockback(hit_data, sign(dir.x))

func _do_damage(damage: int, sender: Node2D, attack_dir: Vector2) -> void:
	ParticleInstancer.blood(_body, attack_dir, 0)
	ParticleInstancer.blood(_body, attack_dir, 1)
	var blink := Tweener.blink(_body, 1, .5, Color.crimson, true)
	Tweener.add_one_off(blink, _body)
	
	# This is a special case wherein knight only gets dealt 1 damage if
	# the damage is small enough. The reason for this is because I want
	# parrys to copy the damage the attack do, and this is just an easy
	# way to do it... But should be fixed. But  this also allows for instant
	# death if something is dealing a lot of damage (like the spikes)
	if get_parent().name == 'Knight' and damage < 100:
		damage = 1
	
	_health.current_set(_health.current - damage, sender)
	
	emit_signal('damage_received', damage)

func _do_knockback(hit_data: Data_Damage, attack_direction: int) -> void:
	if hit_data.knockback_msec != 0 and hit_data.knockback != Vector2.ZERO:
		var knockback := Tweener.knockback(_body, hit_data.knockback, hit_data.knockback_msec, attack_direction * _turner.direction)
		Tweener.add_one_off(knockback, _body)

func _is_parrying(sender: Node2D) -> bool:
	if not _shield: return false
	if not _turner: return false
	
	if not _shield.is_parrying(): return false
	
	var dir := sign(_body.global_position.x - sender.global_position.x)
	return dir == -_turner.direction

func _is_blocking(sender: Node2D) -> bool:
	if not _shield: return false
	if not _turner: return false
	
	if not _shield.is_blocking(): return false
	
	var dir := sign(_body.global_position.x - sender.global_position.x)
	return dir == -_turner.direction







