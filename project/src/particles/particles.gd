extends Node

const Blood := preload('res://src/particles/blood.tscn')
const Explosion := preload('res://src/particles/explosion.tscn')

func blood(node: Node, direction := Vector2.UP, color_variant := 0) -> Node2D:
	var blood := Blood.instance() as CPUParticles2D
	node.add_child(blood)
	blood.direction = direction
	blood.global_position = node.global_position
	
	blood.color_variant(color_variant)
	
	return blood

func explode(node: Node2D, color: Color, amount := 15) -> void:
	var explosion := Explosion.instance() as CPUParticles2D
	explosion.color = color
	node.get_parent().add_child(explosion)
	explosion.emitting = true
	explosion.global_position = node.global_position
	
	yield(get_tree().create_timer(explosion.lifetime), 'timeout')
	
	explosion.queue_free()





