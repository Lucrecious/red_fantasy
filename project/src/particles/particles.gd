extends Node

const Blood := preload('res://src/particles/blood.tscn')

func blood(node: Node2D, direction := Vector2.UP, color_variant := 0) -> Node2D:
	var blood := Blood.instance() as CPUParticles2D
	node.add_child(blood)
	blood.direction = direction
	blood.global_position = node.global_position
	
	blood.color_variant(color_variant)
	
	return blood
