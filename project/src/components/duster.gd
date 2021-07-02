class_name Component_Duster
extends Node2D

const Dust := preload('res://src/characters/final_boss/dust.tscn')

export(int, LAYERS_2D_PHYSICS) var _ground_collision_layer := 0

onready var _turner := NodE.get_sibling(self, Component_Turner) as Component_Turner

func add_dust_on_ground() -> void:
	var dust := Dust.instance() as AnimatedSprite
	dust.show_behind_parent = true
	
	var space := get_world_2d().direct_space_state
	var results := space.intersect_ray(global_position, global_position + Vector2.DOWN * 10000.0, [], _ground_collision_layer)
	
	assert(not results.empty(), 'make sure this is not possible')
	
	get_parent().get_parent().add_child(dust)
	dust.global_position = results.position
	
	if not _turner: return
	
	dust.scale.x *= _turner.direction
	





