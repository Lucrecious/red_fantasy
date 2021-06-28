class_name AI_Actioner
extends Node

signal finished()

onready var _body := NodE.get_ancestor(self, KinematicBody2D) as KinematicBody2D
onready var _turner := NodE.get_child(_body, Component_Turner) as Component_Turner

func attack_combo_by_name(node_name: String, node: Node2D) -> void:
	var attack_combo := NodE.get_child_by_name(_body, node_name) as Component_AttackCombo
	assert(attack_combo, 'this must exist')
	
	attack_combo.attack()
	_turner.direction = sign(node.global_position.x - _body.global_position.x)
	ObjEct.connect_once(attack_combo, 'combo_finished', self, '_on_combo_finished', [attack_combo])

func _on_combo_finished(attack_combo: Component_AttackCombo) -> void:
	ObjEct.disconnect_once(attack_combo, 'combo_finished', self, '_on_combo_finished')
	emit_signal('finished')
