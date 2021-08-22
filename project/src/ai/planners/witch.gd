extends Planner_Abstract

export(bool) var _only_throw := false

onready var _awareness := NodE.get_child_with_error(self, AI_Awareness) as AI_Awareness
onready var _guard := NodE.get_child_with_error(self, AI_Guard) as AI_Guard

func _ready():
	_awareness.connect('target_changed', self, '_on_target_changed')
	_on_target_changed()

func _on_run_ended() -> void:
	if not _awareness.target():
		_chain.add(_guard, 'get_in_position', [])
		_chain.run()
		return
	
	if _only_throw:
		_chain.add(_actioner, 'attack_combo_by_name', ['Throw', _awareness.target(), []])
	else:
		_chain.add(_actioner, 'dynamic_move_to_target', [_awareness.target(), $ThrowRect, 1.0/20.0])
		_chain.add(_actioner, 'attack_combo_by_name', ['Throw', _awareness.target(), []])
	
	_chain.run()

func _on_target_changed() -> void:
	_chain.clear(false)
	_on_run_ended()
