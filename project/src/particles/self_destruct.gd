extends CPUParticles2D

export(PoolColorArray) var _colors := PoolColorArray()

func _ready():
	emitting = true
	
	if not _colors.empty():
		color = _colors[randi() % _colors.size()]
	
	yield(get_tree().create_timer(lifetime), 'timeout')
	queue_free()

func color_variant(index: int) -> void:
	index %= _colors.size()
	if index < 0:
		index += _colors.size()
	
	color = _colors[index]
