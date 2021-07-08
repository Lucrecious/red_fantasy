extends CanvasLayer

onready var _color_rect := $ColorRect as ColorRect

onready var _tween := Tween.new()

func _ready() -> void:
	add_child(_tween)

func fade_in(sec: float) -> void:
	_tween.remove_all()
	
	_tween.interpolate_property(
		_color_rect,
		'modulate:a', _color_rect.modulate.a, 0.0,
		_color_rect.modulate.a * sec, Tween.TRANS_CUBIC)
	
	_tween.start()

func fade_out(sec: float) -> void:
	_tween.remove_all()
	
	_tween.interpolate_property(
		_color_rect,
		'modulate:a', _color_rect.modulate.a, 1.0,
		max(0, 1.0 - _color_rect.modulate.a) * sec, Tween.TRANS_CUBIC)
	
	_tween.start()

func to_opaque() -> void:
	_color_rect.modulate.a = 1.0







