class_name SubComponent_JumpAttackFunctions
extends Node2D

export(int, LAYERS_2D_PHYSICS) var _ground_collision_layer := 0

export(NodePath) var _hammer_spawn_path := NodePath()

onready var _body := NodE.get_ancestor_with_error(self, KinematicBody2D) as KinematicBody2D
onready var _gravity := NodE.get_sibling_with_error(get_parent(), Component_Gravity) as Component_Gravity
onready var _velocity := NodE.get_sibling_with_error(get_parent(), Component_Velocity) as Component_Velocity
onready var _turner := NodE.get_sibling_with_error(get_parent(), Component_Turner) as Component_Turner
onready var _extents := NodE.get_sibling_with_error(get_parent(), Component_Extents) as Component_Extents
onready var _hammer_spawn := NodE.get_node_with_error(self, _hammer_spawn_path, Position2D) as Position2D

var direction := Vector2.ZERO

func stop_down_gravity(time_sec: float) -> void:
	_velocity.value = Vector2.ZERO
	_gravity.add_filter(get_path(), self, '_zero_gravity')
	yield(get_tree().create_timer(time_sec), 'timeout')
	_gravity.remove_filter(get_path())

func throw_hammer(hit_floor_sec: float, alive_sec: float) -> void:
	var thrown_hammer := preload('res://src/characters/final_boss/hammer_thrown.tscn').instance()
	
	var land_position := _land_position(direction)
	
	thrown_hammer.target_location(land_position, hit_floor_sec, alive_sec)
	thrown_hammer.position = Vector2.ZERO
	_hammer_spawn.add_child(thrown_hammer)

func _land_position(dir: Vector2) -> Vector2:
	var space := get_world_2d().direct_space_state
	
	var results := space.intersect_ray(_body.global_position, Vector2.DOWN * 100000.0, [], _ground_collision_layer)
	assert(not results.empty())
	
	var ground_position := results.position as Vector2
	var adj := abs(ground_position.y - _body.global_position.y)
	var theta := abs(rad2deg(Vector2.DOWN.angle_to(dir)))
	theta = clamp(theta, 15.0, 60.0)
	var base := adj * tan(deg2rad(theta))
	return ground_position + Vector2.RIGHT * (base * _turner.direction)

func spawn_sonic_boom() -> void:
	var sonic_boom := preload('res://src/characters/final_boss/sonic_boom.tscn').instance() as AnimatedSprite
	_body.get_parent().add_child(sonic_boom)
	sonic_boom.global_position = _body.global_position
	sonic_boom.scale.x *= _turner.direction

func _zero_gravity(_value: float) -> float:
	return 0.0

func _teleport_to_ground() -> void:
	var land_position := _land_position(direction)
	_body.move_and_collide((land_position + Vector2.UP * _extents.value) - _body.global_position)





