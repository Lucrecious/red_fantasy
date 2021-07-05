class_name AI_Actioner
extends Node

onready var _body := NodE.get_ancestor(self, KinematicBody2D) as KinematicBody2D
onready var _turner := NodE.get_child(_body, Component_Turner) as Component_Turner
onready var _virtual_input := NodE.get_child_with_error(NodE.get_child_with_error(_body, Component_Controller), Input_Virtual) as Input_Virtual

func attack_combo_by_name(node_name: String, node: Node2D, done_event: FuncREf) -> void:
	var attack_combo := NodE.get_child_by_name(_body, node_name) as Component_AttackCombo
	assert(attack_combo, 'this must exist')
	
	var direction := sign(node.global_position.x - _body.global_position.x)
	
	if direction > 0:
		_virtual_input.release('left_move')
		_virtual_input.flash_press('right_move')
	else:
		_virtual_input.release('right_move')
		_virtual_input.flash_press('left_move')
	
	var signal_detector := SignalDetector.new(attack_combo, 'combo_started')
	var test_detector := SignalDetector.new(attack_combo, 'combo_finished')
	attack_combo.attack()
	
	if not signal_detector.raised():
		done_event.call_func()
		return
	
	if test_detector.raised():
		print('on combo finished was already raised')
		return
	ObjEct.connect_once(attack_combo, 'combo_finished', self, '_on_combo_finished', [attack_combo, done_event])

func stop() -> void:
	pass

func _on_combo_finished(attack_combo: Component_AttackCombo, done_event: FuncREf) -> void:
	ObjEct.disconnect_once(attack_combo, 'combo_finished', self, '_on_combo_finished')
	done_event.call_func()
