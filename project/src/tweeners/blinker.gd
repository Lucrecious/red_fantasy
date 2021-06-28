extends Tween

export(Color) var blink_from := Color.white
export(Color) var blink_to := Color.white
export(int) var per_sec := 3
export(int) var blink_count := 3
export(bool) var begin_with_to := false

func _ready():
	var node := get_parent()
	var frac := 1.0 / (per_sec * 2.0)
	
	if begin_with_to:
		var tmp := blink_from
		blink_from = blink_to
		blink_to = tmp
	
	for i in blink_count * 2 if not begin_with_to else blink_count * 2 - 1:
		var from := blink_from if i % 2 == 0 else blink_to
		var to := blink_to if i % 2 == 0 else blink_from
		interpolate_property(node, 'modulate', from, to, frac, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT, i * frac)
