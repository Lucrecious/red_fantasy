extends Planner_Abstract

signal finished_something()

export(float) var _jump_smash_check_sec := .5
export(float) var _jump_attack_check_sec := .5
export(int, LAYERS_2D_PHYSICS) var _walls := 0

onready var _awareness := NodE.get_child_with_error(self, AI_Awareness) as AI_Awareness
onready var _controller := NodE.get_sibling_with_error(self, Component_Controller) as Component_Controller
onready var _virtual_input := NodE.get_child_with_error(_controller, Input_Virtual) as Input_Virtual
onready var _attack_combo := NodE.get_sibling_by_name(self, 'AttackCombo') as Component_AttackCombo
onready var _spin_attack := NodE.get_sibling_by_name(self, 'SpinAttack') as Component_Dodge

onready var _health := NodE.get_sibling_with_error(self, Component_Health) as Component_Health

onready var _dash := NodE.get_sibling_by_name(self, 'Dash') as Component_Dodge
onready var _disabler := NodE.get_sibling_with_error(self, Component_Disabler) as Component_Disabler
onready var _extents := NodE.get_sibling_with_error(self, Component_Extents) as Component_Extents

onready var _jump_smash := NodE.get_sibling_by_name(self, 'JumpSmash') as Component_AttackCombo
onready var _jump_smash_functions := NodE.get_child_with_error(_jump_smash, SubComponent_JumpSmashFunctions) as SubComponent_JumpSmashFunctions

onready var _jump_attack := NodE.get_sibling_by_name(self, 'JumpAttack') as Component_AttackCombo
onready var _jump_attack_functions := NodE.get_child_with_error(_jump_attack, SubComponent_JumpAttackFunctions) as SubComponent_JumpAttackFunctions

onready var _turner := NodE.get_sibling_with_error(self, Component_Turner) as Component_Turner

onready var _attack_combo_range := $AttackComboRange as ReferenceRect
onready var _jump_smash_range := $JumpSmashRange as ReferenceRect
onready var _spin_attack_range := $SpinAttackRange as ReferenceRect
onready var _jump_attack_range := $JumpAttackRange as ReferenceRect

onready var _animation_player := NodE.get_sibling_with_error(self, Component_PriorityAnimationPlayer) as Component_PriorityAnimationPlayer

func _ready() -> void:
	_awareness.connect('target_changed', self, '_on_target_changed')
	
	_health.connect('damaged', self, '_on_damaged')

var _add_cheer := false
func _on_damaged(amount: int) -> void:
	var lower := _health.current
	var upper := lower + amount
	
	if MathE.is_between_inclusive(17, lower, upper):
		_indices.clear()
		_phase += 1
		_add_cheer = true
		return
	
	if MathE.is_between_inclusive(10, lower, upper):
		_indices.clear()
		_phase += 1
		_add_cheer = true
		return
	
	if MathE.is_between_inclusive(2, lower, upper):
		_indices.clear()
		_phase += 1
		_add_cheer = true
		return
	
func _on_run_ended() -> void:
	if not _awareness.target(): return
	
	_move_to_attack(_chain)
	_chain.run()

var _rng := RNG.new()
var _indices: Array

var _phase := 0
var _dodge_percent := 0.0
func _move_to_attack(chain: AI_Chain) -> void:
	if _indices.empty():
		if _phase > 3:
			_phase = 0
		
		match _phase:
			0:
				_indices = _rng.weighted_indices([.4, .2, .4, 0], 10)
				_dodge_percent = 0.0
			1:
				_indices = _rng.weighted_indices([.4, .2, .3, .1], 10)
				_dodge_percent = .2
			2:
				_indices = _rng.weighted_indices([.4, .2, .2, .2], 10)
				_dodge_percent = .5
			3:
				_indices = _rng.weighted_indices([0, .5, .25, .25], 10)
				_dodge_percent = 1.0
		#_indices = _rng.weighted_indices([.0, .0, 1.0, .0], 10)
	
	var index := _indices.pop_back() as int
	
	if _add_cheer:
		_add_cheer = false
		_chain.add(_actioner, 'attack_combo_by_name', ['Cheer', funcref(_awareness, 'target')])
		if _phase == 1:
			index = 3
	
	match index:
		0:
			_chain.add(self, '_dynamic_move_to_target', [funcref(_awareness, 'target'), _attack_combo_range, 1.0/20.0])
			_chain.add(self, '_attack_combo_action', [.7, .77])
		1:
			_chain.add(self, '_dynamic_move_to_target', [funcref(_awareness, 'target'), _jump_smash_range, 1.0/20.0])
			_chain.add(self, '_start_smash_target_update_timer', [_jump_smash_check_sec])
			_chain.add(_actioner, 'attack_combo_by_name', ['JumpSmash', funcref(_awareness, 'target')])
		2:
			_chain.add(self, '_dynamic_move_to_target', [funcref(_awareness, 'target'), _spin_attack_range, 1.0/20.0])
			_chain.add(self, '_spin_attack', [])
		3:
			_chain.add(self, '_dynamic_move_to_target', [funcref(_awareness, 'target'), _jump_attack_range, 1.0/20.0])
			_chain.add(self, '_start_jump_attack_target_update_timer', [_jump_attack_check_sec])
			_chain.add(_actioner, 'attack_combo_by_name', ['JumpAttack', funcref(_awareness, 'target')])

func _dynamic_move_to_target(target: Node2D, rect: ReferenceRect, update_sec: float, done_event: FuncREf) -> void:
	_dynamic_move_to.stop()
	
	var signal_detector := SignalDetector.new(_dynamic_move_to, 'caught_node')
	_dynamic_move_to.target(target, rect, update_sec)
	if signal_detector.raised():
		done_event.call_func()
		return
	
	yield(_dynamic_move_to, 'caught_node')
	
	done_event.call_func()

onready var _jump_attack_update_timer := NodE.add_child(self, TimEr.repeated(.05, self, '_update_jump_attack_direction')) as Timer
func _update_jump_attack_direction() -> void:
	if not _awareness.target(): return
	
	var target_pos := _awareness.target().global_position
	var dir_x := (target_pos - _body.global_position).sign().x
	
	_jump_attack_functions.direction = (_awareness.target().global_position - (_body.global_position + Vector2(dir_x * _extents.value.x * 2, 0))).normalized()

func _start_jump_attack_target_update_timer(sec: float, done_event: FuncREf) -> void:
	_jump_attack_update_timer.start()
	
	done_event.call_func()
	
	yield(get_tree().create_timer(sec), 'timeout')
	
	_jump_attack_update_timer.stop()

onready var _smash_update_timer := NodE.add_child(self, TimEr.repeated(.05, self, '_update_jump_smash_point')) as Timer
func _update_jump_smash_point() -> void:
	if not _awareness.target(): return
	
	var target_pos := _awareness.target().global_position
	var dir_x := (target_pos - _body.global_position).sign().x
	
	_jump_smash_functions.strike_point_relative = target_pos - (_body.global_position + Vector2(dir_x * _extents.value.x * 2.0, 0))

func _start_smash_target_update_timer(sec: float, done_event: FuncREf) -> void:
	_smash_update_timer.start()
	
	done_event.call_func()
	
	yield(get_tree().create_timer(sec), 'timeout')
	
	_smash_update_timer.stop()

func _spin_attack(done_event: FuncREf) -> void:
	if not _awareness.target():
		done_event.call_func()
		return
	
	_turn_towards(_awareness.target().global_position, true, .1)
	
	var success := _spin_attack.dodge(sign(_awareness.target().global_position.x - _body.global_position.x))
	
	if not success:
		done_event.call_func()
		return
	
	var signal_detector := SignalDetector.new(_chain, 'run_ended')
	yield(_spin_attack, 'dodge_ended')
	
	if signal_detector.raised(): return
	
	done_event.call_func()

func _attack_combo_action(check1_sec: float, check2_sec: float, done_event: FuncREf) -> void:
	if not _awareness.target():
		done_event.call_func()
		return
	
	_virtual_input.release('left_move')
	_virtual_input.release('right_move')
	_virtual_input.release('up_move')
	_virtual_input.release('down_move')
	
	var checks := [check1_sec, check2_sec, 0.0]
	for i in 3:
		_turn_towards(_awareness.target().global_position)
		
		_attack_combo.attack()
		
		var check := checks[i] as float
		if check == 0.0:
			if _attack_combo.is_attacking():
				yield(_attack_combo, 'combo_finished')
			
			done_event.call_func()
			return
		
		yield(get_tree().create_timer(check), 'timeout')
	
		if not _attack_combo.is_attacking() or not _awareness.target() or not _within_combo_range():
			if _attack_combo.is_attacking():
				yield(_attack_combo, 'combo_finished')
		
			done_event.call_func()
			return
	
	done_event.call_func()

func _turn_towards(position: Vector2, hold := false, hold_sec := 0.0) -> void:
	var side := sign(position.x - _body.global_position.x)
	if not hold and hold_sec <= 0.0:
		if side < 0:
			_virtual_input.flash_press('left_move')
		else:
			_virtual_input.flash_press('right_move')
	else:
		if side < 0:
			_virtual_input.press_sec('left_move', 0.0, hold_sec)
		else:
			_virtual_input.press_sec('right_move', 0.0, hold_sec)

func _within_combo_range() -> bool:
	if not _awareness.target(): return false
	
	var rect1 := _attack_combo_range.get_global_rect()
	var rect2 := _attack_combo_range.get_rect()
	rect2.position *= Vector2(-1, 1)
	rect2.size *= Vector2(-1, 1)
	rect2 = rect2.abs()
	rect2.position += _body.global_position
	
	var target_rect := NodE.get_child(_awareness.target(), Component_Extents) as Component_Extents
	if not target_rect or (not rect1.intersects(target_rect.get_as_global_rect()) and not rect2.intersects(target_rect.get_as_global_rect())):
		return false
	
	return true

var _previous_target: Node2D
var _attack_hints: Component_AttackHints
func _on_target_changed() -> void:
	_chain.clear()
	
	if _previous_target == _awareness.target(): return
	
	if _previous_target:
		if _attack_hints:
			_attack_hints.disconnect('attack_started', self, '_on_attack_started')
			_attack_hints = null
	
	_previous_target = _awareness.target()
	
	if _previous_target:
		_attack_hints = NodE.get_child(_previous_target, Component_AttackHints) as Component_AttackHints
		if _attack_hints:
			_attack_hints.connect('attack_started', self, '_on_attack_started')
	
	if _awareness.target():
		_move_to_attack(_chain)
		_chain.run()
	else:
		_dynamic_move_to.stop()
		_move_to.stop()
		_actioner.stop()

func _on_attack_started(animation: String, rect: Rect2, sec_to_impact: float) -> void:
	if _dash.is_dodging(): return
	
	var this_rect := _extents.get_as_global_rect()
	if not GEometry.rects_touch(rect, this_rect): return
	var real := max(0, sec_to_impact - .1)
	if real > 0:
		yield(get_tree().create_timer(real), 'timeout')
	
	if not _awareness.target(): return
	
	if _dodge_percent + randf() < 1: return
	
	var target_position := _awareness.target().global_position
	
	var away_dir := (_body.global_position - target_position).sign().x
	
	var space := get_world_2d().direct_space_state
	var results := space.intersect_ray(global_position, global_position + Vector2.RIGHT * away_dir * 32, [], _walls)
	if not results.empty():
		away_dir *= -1
		
	_chain.clear(false)
	
	if away_dir > 0:
		_virtual_input.flash_press('right_move')
	elif away_dir < 0:
		_virtual_input.flash_press('left_move')
	
	_virtual_input.flash_press('dodge')
	
	if not _dash.is_dodging():
		_on_run_ended()
		return
	
	yield(_dash, 'dodge_ended')
	
	_on_run_ended()
