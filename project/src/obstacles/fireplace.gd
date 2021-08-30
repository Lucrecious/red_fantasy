extends AnimatedSprite

export(int, LAYERS_2D_PHYSICS) var _player_collision := 0

onready var _area := $Area as Area2D
onready var _fire := $Fire as CPUParticles2D
onready var _first_time := $FirstTime as CPUParticles2D

var gottened := false

func _ready():
	playing = true
	
	_area.connect('body_entered', self, '_on_body_entered')
	
	_first_time.one_shot = true
	_first_time.emitting = false
	_fire.emitting = false
	
	$FireSound.play()

func _on_body_entered(body: KinematicBody2D) -> void:
	if gottened: return
	gottened = true
	
	Sound.play(Sound.FireHit, self)
	
	var initializer := NodE.get_child_with_error(body, Component_Initializer) as Component_Initializer
	if initializer:
		initializer.spawn_position = global_position
	
	var health := NodE.get_child_with_error(body, Component_Health) as Component_Health
	if health:
		health.current = 2 #TODO: Store somewhere better
	
	_fire.emitting = true
	_first_time.emitting = true
