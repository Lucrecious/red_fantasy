extends Node

signal all_enemies_just_died()

export(Array, NodePath) var _enemy_paths := []

func _ready() -> void:
	for path in _enemy_paths:
		var enemy := get_node_or_null(path)
		if not enemy:
			return
		
		var death := NodE.get_child(enemy, Component_Death) as Component_Death
		if not death:
			return

		death.connect('died', self, '_on_died')
	
var _death_count := 0
func _on_died() -> void:
	_death_count += 1

	if _death_count != _enemy_paths.size():
		return
	
	emit_signal('all_enemies_just_died')

func reset() -> void:
	_death_count = 0
