extends CPUParticles2D

export(float) var _block_velocity := 70.0
export(float) var _parry_velocity := 100.0

export(Color) var _block_color := Color.white
export(Color) var _parry_color := Color.lightblue

func block() -> void:
	initial_velocity = _block_velocity
	modulate = _block_color
	emitting = true
	yield(get_tree().create_timer(.2), 'timeout')
	emitting = false

func parry() -> void:
	initial_velocity = _parry_velocity
	modulate = _parry_color
	emitting = true
	yield(get_tree().create_timer(.2), 'timeout')
	emitting = false




