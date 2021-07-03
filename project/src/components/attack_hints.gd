class_name Component_AttackHints
extends Node2D

signal attack_started(animation, global_rect, sec_to_impact)

export(Array, NodePath) var _attack_combo_paths := []
export(Array, NodePath) var _reference_paths := []
export(Array, String) var _attack_combo_animations := []
export(Array, float) var _secs_until_hit := []

onready var _animation_to_hit_sec := {}
onready var _animation_to_reference := {}

func _ready() -> void:
	assert(_attack_combo_paths.size() == _attack_combo_animations.size())
	assert(_attack_combo_paths.size() == _secs_until_hit.size())
	assert(_attack_combo_paths.size() == _reference_paths.size())
	
	for i in _attack_combo_paths.size():
		var path := _attack_combo_paths[i] as NodePath
		var combo := NodE.get_node_with_error(self, path, Component_AttackCombo) as Component_AttackCombo
		
		var animation := _attack_combo_animations[i] as String
		var reference := NodE.get_node_with_error(self, _reference_paths[i], REferenceRect) as REferenceRect
		var sec := _secs_until_hit[i] as float
		
		_animation_to_hit_sec[animation] = sec
		_animation_to_reference[animation] = reference
		
		ObjEct.connect_once(combo, 'combo_started', self, '_on_combo_started')

func _on_combo_started(animation: String) -> void:
	var sec_to_impact := _animation_to_hit_sec[animation] as float
	var reference := _animation_to_reference[animation] as REferenceRect
	emit_signal('attack_started', animation, reference.global_rect(), sec_to_impact)









