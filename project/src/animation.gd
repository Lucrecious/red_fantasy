class_name Component_PriorityAnimationPlayer
extends AnimationPlayer

func _ready() -> void:
	connect('animation_finished', self, '_on_animation_finished')
	
	for child in get_children():
		var signal_expression := child as SignalExpression
		if signal_expression:
			signal_expression.connect('conditions_met', self, '_on_conditions_met', [signal_expression])
			signal_expression.connect('conditions_unmet', self, '_on_conditions_unmet', [signal_expression])
			continue
		
		var signal_callback := child as SignalAnimationFinishedCallback
		if signal_callback:
			signal_callback.connect('called', self, '_on_signal_callback_called', [signal_callback])
			continue
		assert(false, 'not recognized type')
		continue

# override to include extra signal
func play(name: String = "", custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false):
	if current_animation == name: return
	assert(has_animation(name))
	var old := current_animation
	.play(name, custom_blend, custom_speed, from_end)
	emit_signal('animation_changed', old, current_animation)

var _playing_for_callback := false
var _play_priority := -1

func _on_conditions_met(sender: SignalExpression) -> void:
	if _play_priority > sender.get_index(): return
	
	play(sender.condition_key)
	
	_play_priority = sender.get_index()

func _on_signal_callback_called(sender: SignalAnimationFinishedCallback) -> void:
	if _play_priority > sender.get_index(): return
	
	play(sender.animation_name)
	
	_play_priority = sender.get_index()
	_playing_for_callback = true

func _on_animation_finished(_animation_name: String) -> void:
	if not _playing_for_callback: return
	_playing_for_callback = false
	
	var index := _play_priority
	_play_priority = -1
	_play_next_highest_priority_expression(index)

func _on_animation_changed(_animation_name: String) -> void:
	if not _playing_for_callback: return
	_playing_for_callback = false
	
	var index := _play_priority
	_play_priority = -1
	_play_next_highest_priority_expression(index)

func _on_conditions_unmet(sender: SignalExpression) -> void:
	if _play_priority > sender.get_index(): return
	if _play_priority < sender.get_index(): return
	var index := _play_priority
	_play_priority = -1
	_play_next_highest_priority_expression(index)

func _play_next_highest_priority_expression(index: int) -> void:
	for i in range(0, index):
		var li := (index - 1) - i
		var expression := get_child(li) as SignalExpression
		if not expression: continue
		if not expression.is_true(): continue
		_on_conditions_met(expression)
		return




