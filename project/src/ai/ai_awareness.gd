class_name AI_Awareness
extends Node2D

signal target_changed()

export(NodePath) var _awareness_area_path := NodePath()
export(NodePath) var _eyes_path := NodePath()
export(float) var _max_angle_deg := 45
export(int, LAYERS_2D_PHYSICS) var _collision := 0

onready var _body := NodE.get_ancestor(self, KinematicBody2D) as KinematicBody2D
onready var _turner := NodE.get_child(_body, Component_Turner) as Component_Turner
onready var _awareness_area := get_node_or_null(_awareness_area_path) as Area2D
onready var _eyes := get_node_or_null(_eyes_path) as Node2D

var _possible_targets := {}
var _current_target: Node2D

func _ready() -> void:
	assert(_body, 'must be present')
	assert(_awareness_area, 'must be set')
	assert(_turner, 'must be present')
	
	_awareness_area.connect('body_entered', self, '_on_body_entered')
	_awareness_area.connect('body_exited', self, '_on_body_exited')
	
	var health := NodE.get_child(_body, Component_Health) as Component_Health
	if health:
		health.connect('damaged', self, '_aggro', [health])
	
	var timer := Timer.new()
	timer.wait_time = .1
	timer.autostart = true
	timer.one_shot = false
	timer.connect('timeout', self, '_sees_target')
	add_child(timer)

func target() -> Node2D: return _current_target

func _aggro(amount: int, health: Component_Health) -> void:
	var body := health.last_health_modifier() as KinematicBody2D
	if not body: return
	
	if not body in _possible_targets: return
	
	_current_target_set(body)

func _sees_target() -> void:
	if _current_target and _current_target in _possible_targets: return
	
	if _possible_targets.empty():
		_current_target_set(null)
		return
	
	if not _eyes:
		_current_target_set(_possible_targets[0])
		return
		
	var space := get_world_2d().direct_space_state
	
	var eye_pos := _eyes.position
	eye_pos.x *= _turner.direction
	eye_pos = _eyes.to_global(eye_pos)
	
	for t in _possible_targets:
		var delta := (t.global_position - eye_pos) as Vector2
		if not ((delta.x < 0 and _turner.direction < 0) or (delta.x > 0 and _turner.direction > 0)): continue
		if rad2deg(_eyes.global_position.angle_to_point(t.global_position)) > _max_angle_deg: continue
		
		var results := space.intersect_ray(eye_pos, t.global_position, [], _collision)
		if not results.empty(): continue
		
		_current_target_set(t)
		break

func _current_target_set(target: Node2D) -> void:
	if _current_target == target: return
	
	if _current_target:
		_current_target.disconnect('tree_exiting', self, '_current_target_set')
	
	_current_target = target
	
	if _current_target:
		_current_target.connect('tree_exiting', self, '_current_target_set', [null])
		
	emit_signal('target_changed')

func _on_body_entered(body: KinematicBody2D) -> void:
	_possible_targets[body] = true

func _on_body_exited(body: KinematicBody2D) -> void:
	_possible_targets.erase(body)







