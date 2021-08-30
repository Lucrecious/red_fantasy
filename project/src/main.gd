extends Node2D

export(NodePath) var _custom_spawn_location_path := NodePath()

func _ready():
	FadeInOuter.to_opaque()
	
	yield(get_tree().create_timer(1.0), 'timeout')
	
	FadeInOuter.fade_in(1.0)
	
	var player := get_tree().get_nodes_in_group('player')[0] as KinematicBody2D
	var death := NodE.get_child_with_error(player, Component_Death) as Component_Death
	
	var controller := NodE.get_child_with_error(player, Component_Controller)
	var virtual_input := Input_Virtual.new()
	death.connect('died', self, '_on_player_died', [controller, virtual_input])
	
	var final_boss := get_tree().get_nodes_in_group('boss')[0] as KinematicBody2D
	var boss_death := NodE.get_child_with_error(final_boss, Component_Death) as Component_Death
	boss_death.connect('died', self, '_on_boss_died', [], CONNECT_ONESHOT)
	
	if _custom_spawn_location_path.is_empty():
		return
	
	var location := get_node_or_null(_custom_spawn_location_path) as Node2D
	if not location:
		return
	
	yield(get_tree(), 'idle_frame')
	player.global_position = location.global_position
	var initializer := NodE.get_child(player, Component_Initializer) as Component_Initializer
	initializer.spawn_position = location.global_position
	

func _on_boss_died() -> void:
	Music.play(Music.Wind1)
	
	yield(get_tree().create_timer(3.0), 'timeout')
	
	Sound.play(Sound.BossWin, null)
	
	yield(get_tree().create_timer(5.0), 'timeout')
	
	$BackgroundMap/ThanksForPlaying.appear()

var _dying := false
func _on_player_died(controller: Component_Controller, virtual_input: Input_Abstract) -> void:
	if _dying:
		return
	
	_dying = true
	var input := NodE.get_child_with_error(controller, Input_Abstract) as Input_Abstract
	
	controller.use_custom_input(virtual_input)
	
	yield(get_tree().create_timer(2.0), 'timeout')
	
	FadeInOuter.fade_out(1.2)
	
	yield(get_tree().create_timer(1.2), 'timeout')
	
	get_tree().call_group('initializer', 'reinit')
	get_tree().call_group('door', 'reset')
	get_tree().call_group('condition', 'reset')
	
	yield(get_tree().create_timer(.25), 'timeout')
	
	
	FadeInOuter.fade_in(1.2)
	
	controller.use_custom_input(input)
	
	_dying = false







