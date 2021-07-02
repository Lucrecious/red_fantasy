class_name Component_DamageReceiver
extends Node

onready var _body := NodE.get_ancestor_with_error(self, KinematicBody2D) as KinematicBody2D
onready var _health := NodE.get_sibling_with_error(self, Component_Health) as Component_Health
onready var _dodge := NodE.get_sibling(self, Component_Dodge) as Component_Dodge
onready var _shield := NodE.get_sibling(self, Component_Shield) as Component_Shield
onready var _turner := NodE.get_sibling(self, Component_Turner) as Component_Turner

func bleed_attack(sender: Node2D, hit_data: Data_Damage) -> void:
	var dir := _body.global_position - sender.global_position
	dir.y = -abs(dir.y)
	
	var is_dodge_immune := _dodge and _dodge.is_immune()
	var is_blocking := _is_blocking(sender)
	
	if is_dodge_immune or is_blocking: pass
	else:
		ParticleInstancer.blood(_body, dir, 0)
		ParticleInstancer.blood(_body, dir, 1)
		var blink := Tweener.blink(_body, 1, .5, Color.crimson, true)
		Tweener.add_one_off(blink, _body)
		
		_health.current_set(_health.current - hit_data.damage, sender)
	
	if is_dodge_immune: pass
	else:
		if hit_data.knockback_msec != 0 and hit_data.knockback != Vector2.ZERO:
			var knockback := Tweener.knockback(_body, hit_data.knockback, hit_data.knockback_msec, sign(dir.x) * _turner.direction)
			Tweener.add_one_off(knockback, _body)
	

func _is_blocking(sender: Node2D) -> bool:
	if not _shield: return false
	if not _turner: return false
	
	if not _shield.is_blocking(): return false
	
	var dir := sign(_body.global_position.x - sender.global_position.x)
	return dir == -_turner.direction







