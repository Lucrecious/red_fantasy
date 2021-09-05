class_name Component_Scorer
extends Node

signal points_scored()

export(bool) var repeatable := false
export(int) var points := 0

var _already_done := false
func trigger(_1=null, _2=null, _3=null, _4=null, _5=null, _6=null) -> void:
	if not repeatable and _already_done:
		return
	_already_done = true
	emit_signal('points_scored')
