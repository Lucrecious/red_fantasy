extends MarginContainer

export(NodePath) var _score_counter_path := NodePath()

onready var _score_counter := NodE.get_node_with_error(self, _score_counter_path, Game_ScoreCounter) as Game_ScoreCounter
onready var _tween := NodE.add_child(self, Tween.new()) as Tween
onready var _label := $Label as Label

func _ready() -> void:
	_score_counter.connect('total_changed', self, '_on_total_changed')
	_on_total_changed()

var _display_score := 0 setget _display_score_set
func _on_total_changed() -> void:
	_tween.stop_all()
	_tween.remove_all()
	
	_tween.interpolate_property(self, '_display_score', _display_score, _score_counter.total, 1.0)
	_tween.start()

func _display_score_set(value: int) -> void:
	_display_score = value
	var display := str(_display_score)
	if _display_score < 0:
		display = 'minus %s' % display
	
	_label.text = display
