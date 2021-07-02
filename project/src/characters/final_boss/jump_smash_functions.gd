class_name SubComponent_JumpSmashFunctions
extends Node2D

export(int, LAYERS_2D_PHYSICS) var _collision := 0
export(float) var _deg_min_from_down := 1.0
export(float) var _deg_max_from_down := 45.0

onready var _body := NodE.get_ancestor(self, KinematicBody2D) as KinematicBody2D
onready var _gravity := NodE.get_sibling_with_error(get_parent(), Component_Gravity) as Component_Gravity
onready var _velocity := NodE.get_sibling_with_error(get_parent(), Component_Velocity) as Component_Velocity
onready var _turner := NodE.get_sibling_with_error(get_parent(), Component_Turner) as Component_Turner
onready var _extents := NodE.get_sibling_with_error(get_parent(), Component_Extents) as Component_Extents

var strike_point_relative := Vector2(500, 500)

func lower_gravity(sec: float) -> void:
	_gravity.add_filter(get_path(), self, '_reduced_gravity')
	yield(get_tree().create_timer(sec), 'timeout')
	_gravity.remove_filter(get_path())

func _reduced_gravity(value: float) -> float:
	_velocity.x /= 2.0
	_velocity.y /= 6.0
	return value / 6.0

func move_to_ground(sec: float) -> void:
	var space := get_world_2d().direct_space_state
	
	var strike_point_relative := self.strike_point_relative
	
	var angle := _deg_min_from_down
	if _turner.direction == sign(strike_point_relative.x):
		angle = abs(rad2deg(Vector2.DOWN.angle_to(strike_point_relative)))
	
	angle = clamp(angle, _deg_min_from_down, _deg_max_from_down)
	var results := space.intersect_ray(_body.global_position, _body.global_position + Vector2.DOWN * 1000.0, [], _collision)
	
	if results.empty(): return
	
	var position := results.position as Vector2
	var down_distance := abs(position.y - _body.global_position.y)
	var offset_x := (down_distance * tan(deg2rad(angle))) * _turner.direction + (_extents.value.x * -_turner.direction)
	position.x += offset_x
	
	var displacement := (position - _body.global_position)
	
	var speed := (displacement.length() / _velocity.units) / (sec / 1.3)
	_velocity.value = displacement.normalized() * speed
	
	yield(get_tree().create_timer(sec), 'timeout')
	
	if not _body.is_on_floor():
		_body.move_and_collide(position - _body.global_position)
	
	_velocity.value = Vector2.ZERO
	






