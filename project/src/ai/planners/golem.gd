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
	_chain.add(self, '_dynamic_move_to_target', [funcref(_awareness, 'target'), $PunchRect, 1.0/20.0])
	_chain.add(_actioner, 'attack_combo_by_name', ['Punch', funcref(_awareness, 'target')])

func _dynamic_move_to_target(target: Node2D, rect: ReferenceRect, update_sec: float, done_event: FuncREf) -> void:
	_dynamic_move_to.stop()
	
	var signal_detector := SignalDetector.new(_dynamic_move_to, 'caught_node')
	_dynamic_move_to.target(target, rect, update_sec)
	if signal_detector.raised():
		done_event.call_func()
		return
	
	yield(_dynamic_move_to, 'caught_node')
	
	done_event.call_func()

var _previous_target: Node2D
func _on_target_changed() -> void:
	_chain.clear()
	
	if _awareness.target():
		if not _previous_target:
			_chain.add(_actioner, 'attack_combo_by_name', ['BangHands', funcref(_awareness, 'target')])
		
		_move_to_attack(_chain)
		_chain.run()
	else:
		_dynamic_move_to.stop()
		_move_to.stop()
		_actioner.stop()
	
	_previous_target = _awareness.target()
