extends Label

const letters_per_sec := 20.0

var _showing := false

onready var _tween := Tween.new()

func _ready() -> void:
	add_child(_tween)
	
	percent_visible = 0

func appear() -> void:
	if _showing: return
	_showing = true
	
	_tween.remove_all()
	_tween.interpolate_property(self, 'percent_visible', percent_visible, 1.0, max(0, ((1.0 - percent_visible) * text.length()) / letters_per_sec))
	_tween.start()

func disappear() -> void:
	if not _tween.is_inside_tree(): return # For some reason, on close, this is called
	if not _showing: return
	_showing = false
	
	_tween.remove_all()
	_tween.interpolate_property(self, 'percent_visible', percent_visible, 0.0, max(0, (percent_visible * text.length()) / letters_per_sec))
	_tween.start()
