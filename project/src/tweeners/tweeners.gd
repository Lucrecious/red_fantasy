extends Node

const Blinker := preload('res://src/tweeners/blinker.gd')

func blink(node: CanvasItem, amount: int, seconds: float, color: Color, begin_with_to: bool, color_from := Color.white) -> Tween:
	var blinker := Blinker.new()
	blinker.blink_from = color_from
	blinker.blink_to = color
	blinker.per_sec = float(amount / seconds)
	blinker.blink_count = amount
	blinker.begin_with_to = begin_with_to
	
	return blinker

func knockback(node: Node2D, velocity: Vector2, time_msec: int, dir: int) -> Tween:
	assert(abs(dir) == 1)
	var pusher := NodE.get_child(node, Component_Pusher) as Component_Pusher
	if not pusher: return null
	
	var tween := Tween.new()
	tween.interpolate_property(pusher, 'x', dir * velocity.x, 0, time_msec / 1000.0, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	tween.interpolate_property(pusher, 'y', velocity.y, 0, time_msec / 1000.0, Tween.TRANS_EXPO, Tween.EASE_IN_OUT)
	
	return tween

func add_one_off(tween: Tween, parent_overide: Node = null) -> void:
	if not tween: return
	
	if parent_overide:
		parent_overide.add_child(tween)
	else:
		add_child(tween)
	
	tween.start()
	yield(get_tree().create_timer(tween.get_runtime() * 1.1), 'timeout')
	tween.queue_free()
