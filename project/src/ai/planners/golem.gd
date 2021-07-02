extends Planner_Abstract

onready var _awareness := NodE.get_child(self, AI_Awareness) as AI_Awareness

func _ready() -> void:
	return
	_awareness.connect('target_changed', self, '_on_target_changed')

func _on_run_ended() -> void:
	if not _awareness.target(): return
	
	_move_to_attack(_chain)
	_chain.run()

func _move_to_attack(chain: AI_Chain) -> void:
	_chain.add(_dynamic_move_to, 'target', [funcref(_awareness, 'target'), $PunchRect, 1.0/20.0], 'caught_node')
	_chain.add(_actioner, 'attack_combo_by_name', ['Punch', funcref(_awareness, 'target')], 'finished')

var _previous_target: Node2D
func _on_target_changed() -> void:
	_chain.clear()
	
	if _awareness.target():
		if not _previous_target:
			_chain.add(_actioner, 'attack_combo_by_name', ['BangHands', funcref(_awareness, 'target')], 'finished')
		
		_move_to_attack(_chain)
		_chain.run()
	else:
		_dynamic_move_to.stop()
		_move_to.stop()
		_actioner.stop()
	
	_previous_target = _awareness.target()
