extends Area2D

signal body_Entered()
signal body_Exited()
signal arEa_entered()
signal arEa_exited()

func _ready() -> void:
	connect('body_entered', self, '_on_body_entered')
	connect('body_exited', self, '_on_body_exited')
	connect('area_entered', self, '_on_area_entered')
	connect('area_exited', self, '_on_area_exited')

func _on_body_entered(__=null) -> void: emit_signal('body_Entered')
func _on_body_exited(__=null) -> void: emit_signal('body_Exited')
func _on_area_entered(__=null) -> void: emit_signal('arEa_entered')
func _on_area_exited(__=null) -> void: emit_signal('arEa_exited')
