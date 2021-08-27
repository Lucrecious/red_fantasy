class_name AI_Actioner
extends Node

onready var _body := NodE.get_ancestor(self, KinematicBody2D) as KinematicBody2D
onready var _turner := NodE.get_child(_body, Component_Turner) as Component_Turner
onready var _virtual_input := NodE.get_child_with_error(NodE.get_child_with_error(_body, Component_Controller), Input_Virtual) as Input_Virtual

onready var _dynamic_move_to := NodE.get_sibling_with_error(self, AI_DynamicMoveTo) as AI_DynamicMoveTo

func dynamic_move_to_target(target: Node2D, rect: ReferenceRect, update_sec: float, done_event: FuncREf) -> void:
	_dynamic_move_to.stop()
	
	var signal_detector := SignalDetector.new(_dynamic_move_to, 'caught_node')
	_dynamic_move_to.target(target, rect, update_sec)
	if signal_detector.raised():
		done_event.call_func()
		return
	
	ObjEct.connect_once(_dynamic_move_to, 'caught_node', self, '_on_caught_node', [done_event])

func _on_caught_node(done_event: FuncREf) -> void:
	ObjEct.disconnect_once(_dynamic_move_to, 'caught_node', self, '_on_caught_node')
	done_event.call_func()

func wait(sec: float, direction: int, done_event: FuncREf) -> void:
	_virtual_input.flash_direction_x(direction)
	
	yield(get_tree().create_timer(sec), 'timeout')
	
	done_event.call_func()

func attack_combo_by_name(node_name: String, node: Node2D, other_input: PoolStringArray, done_event: FuncREf) -> void:
	_attack_combo_by_name(node_name, node, other_input, 'attack', done_event)

func dodge_combo_by_name(node_name: String, node: Node2D, other_input: PoolStringArray, done_event: FuncREf) -> void:
	_attack_combo_by_name(node_name, node, other_input, 'dodge', done_event)

func _attack_combo_by_name(node_name: String, node: Node2D, other_input: PoolStringArray, action: String, done_event: FuncREf) -> void:
	var attack_combo := NodE.get_child_by_name(_body, node_name) as Component_AttackCombo
	assert(attack_combo, 'this must exist')
	
	var direction := sign(node.global_position.x - _body.global_position.x)
	
	_virtual_input.flash_direction_x(int(direction))

	for i in 4:
		yield(get_tree(), 'idle_frame')
	
	var signal_detector := SignalDetector.new(attack_combo, 'combo_started')
	for input in other_input:
		_virtual_input.flash_press(input);

	_virtual_input.flash_press(action)
	
	if not signal_detector.raised():
		done_event.call_func()
		return
	
	ObjEct.connect_once(attack_combo, 'combo_finished', self, '_on_combo_finished', [attack_combo, done_event])

func stop() -> void:
	pass

func _on_combo_finished(attack_combo: Component_AttackCombo, done_event: FuncREf) -> void:
	ObjEct.disconnect_once(attack_combo, 'combo_finished', self, '_on_combo_finished')
	done_event.call_func()
