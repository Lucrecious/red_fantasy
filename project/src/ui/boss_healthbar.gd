class_name BossHealthBar
extends Control

signal finished()

onready var _progress_bar := $CenterContainer/ProgressBar as TextureProgress

func _ready() -> void:
	visible = false

func start(body: Node2D) -> void:
	if is_connected('finished', self, '_on_finished'):
		end()
	
	visible = true
	
	var health := NodE.get_child(body, Component_Health) as Component_Health
	assert(health, 'must be present')
	
	health.connect('damaged', self, '_on_damaged', [health])
	health.connect('increased', self, '_on_increased', [health])
	
	_progress_bar.max_value = health.current
	_progress_bar.value = health.current
	
	connect('finished', self, '_on_finished', [health], CONNECT_ONESHOT)
	
func _on_damaged(_1, health: Component_Health) -> void:
	_progress_bar.value = health.current

func _on_increased(_1, health: Component_Health) -> void:
	_progress_bar.value = health.current

func _on_finished(health: Component_Health) -> void:
	health.disconnect('damaged', self, '_on_damaged')
	health.disconnect('increased', self, '_on_increased')

func end() -> void:
	visible = false
	emit_signal('finished')
