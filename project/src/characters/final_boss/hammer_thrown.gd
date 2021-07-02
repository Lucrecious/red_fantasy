extends KinematicBody2D

onready var _velocity := NodE.get_child_with_error(self, Component_Velocity) as Component_Velocity
onready var _animation := NodE.get_child_with_error(self, AnimationPlayer) as AnimationPlayer

var _initialized := false
var _location: Vector2
var _hit_floot_sec: float
var _alive_sec: float

func target_location(value: Vector2, hit_floor_sec: float, alive_sec: float) -> void:
	_initialized = true
	_location = value
	_hit_floot_sec = hit_floor_sec
	_alive_sec = alive_sec

var _required_velocity: Vector2
func _ready() -> void:
	assert(_initialized, 'must be initialized before added into scene')
	
	var delta := _location - global_position
	var speed := (delta.length() / _hit_floot_sec) / _velocity.units
	
	_required_velocity = delta.normalized() * speed
	
	_velocity.connect('floor_hit', self, '_on_floor_hit')
	
	_animation.play('spin')
	
	yield(get_tree().create_timer(_alive_sec), 'timeout')
	
	queue_free()

func _on_floor_hit() -> void:
	set_physics_process(false)
	_velocity.value = Vector2.ZERO
	
	_animation.play('land')

func _physics_process(_delta: float) -> void:
	_velocity.value = _required_velocity




