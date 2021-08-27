extends Node2D

func _ready():
	FadeInOuter.to_opaque()
	
	yield(get_tree().create_timer(1.0), 'timeout')
	
	FadeInOuter.fade_in(1.0)
	
	var player := get_tree().get_nodes_in_group('player')[0] as KinematicBody2D
	var death := NodE.get_child_with_error(player, Component_Death) as Component_Death
	
	var controller := NodE.get_child_with_error(player, Component_Controller)
	var virtual_input := Input_Virtual.new()
	death.connect('died', self, '_on_player_died', [controller, virtual_input])

func _on_player_died(controller: Component_Controller, virtual_input: Input_Abstract) -> void:
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







