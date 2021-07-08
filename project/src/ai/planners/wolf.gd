extends Planner_Abstract

export(NodePath) var _consider_rect_path := NodePath()

onready var _awareness := NodE.get_child(self, AI_Awareness) as AI_Awareness
onready var _consider_rect := NodE.get_node_with_error(self, _consider_rect_path, REferenceRect) as REferenceRect 

func _ready() -> void:
	_awareness.connect('target_changed', self, '_on_target_changed')
	_on_target_changed()

func _on_run_ended() -> void:
	_dynamic_move_to.stop()
	_move_to.stop()
	_actioner.stop()
	
	if _awareness.target():
		_move_to_attack(_chain)
		_chain.run()
	else:
		_chain.add(self, '_move_to', [_consider_rect.random_global_point_inside()])
		_chain.add(_actioner, 'wait', [1.0 + randf() * 1.0, 0])
		_chain.run()

func _move_to(location: Vector2, done_event: FuncREf) -> void:
	_move_to.target(location)
	yield(_move_to, 'arrived_at_target')
	done_event.call_func()

func _move_to_attack(chain: AI_Chain) -> void:
	_chain.add(self, '_dynamic_move_to_target', [funcref(_awareness, 'target'), $BiteRect, 1.0/20.0])
	_chain.add(_actioner, 'attack_combo_by_name', ['Bite', funcref(_awareness, 'target')])

func _dynamic_move_to_target(target: Node2D, rect: ReferenceRect, update_sec: float, done_event: FuncREf) -> void:
	_dynamic_move_to.stop()
	
	var signal_detector := SignalDetector.new(_dynamic_move_to, 'caught_node')
	_dynamic_move_to.target(target, rect, update_sec)
	if signal_detector.raised():
		done_event.call_func()
		return
	
	yield(_dynamic_move_to, 'caught_node')
	
	done_event.call_func()

func _on_target_changed() -> void:
	_chain.clear(false)
	_on_run_ended()
