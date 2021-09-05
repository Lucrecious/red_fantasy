class_name Game_ScoreCounter
extends Node

signal total_changed()

var total := 0 setget _total_set

var grand_total := 0

func _ready():
	yield(get_tree().create_timer(.1), 'timeout')
	for scorer in get_tree().get_nodes_in_group('scorer'):
		scorer.connect('points_scored', self, '_on_points_scored', [scorer])
		
		if scorer.points < 0:
			continue
		
		grand_total += scorer.points

func _on_points_scored(scorer: Component_Scorer) -> void:
	_total_set(total + scorer.points)

func _total_set(value: int) -> void:
	if total == value:
		return
	
	total = value
	emit_signal('total_changed')
