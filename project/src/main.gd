extends Node2D

export(NodePath) var _custom_spawn_location_path := NodePath()

func _ready():
	FadeInOuter.to_opaque()
	
	yield(get_tree().create_timer(1.0), 'timeout')
	
	FadeInOuter.fade_in(1.0)
	
	var player := get_tree().get_nodes_in_group('player')[0] as KinematicBody2D
	var death := NodE.get_child_with_error(player, Component_Death) as Component_Death
	var damage_receiver := NodE.get_child_with_error(player, Component_DamageReceiver) as Component_DamageReceiver
	
	var controller := NodE.get_child_with_error(player, Component_Controller)
	var virtual_input := Input_Virtual.new()
	death.connect('died', self, '_on_player_died', [controller, virtual_input, NodE.get_child_with_error(player, CollisionShape2D)])
	
	damage_receiver.connect('damage_received', self, '_shake_camera')
	
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

onready var _camera_shake := $Camera_Game/Shake
func _shake_camera(_damage: int) -> void:
	_camera_shake.add_trauma(1.0)

func _on_boss_died() -> void:
	Music.play(Music.Wind1)
	
	yield(get_tree().create_timer(3.0), 'timeout')
	
	Sound.play(Sound.BossWin, null)
	
	yield(get_tree().create_timer(5.0), 'timeout')
	
	$BackgroundMap/ThanksForPlaying.appear()

var _dying := false
func _on_player_died(controller: Component_Controller, virtual_input: Input_Abstract, collision: CollisionShape2D) -> void:
	if _dying:
		return
	
	_dying = true
	var input := NodE.get_child_with_error(controller, Input_Abstract) as Input_Abstract
	
	collision.set_deferred('disabled', true)
	
	controller.use_custom_input(virtual_input)
	
	yield(get_tree().create_timer(2.0), 'timeout')
	
	FadeInOuter.fade_out(1.2)
	
	yield(get_tree().create_timer(1.2), 'timeout')
	
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, 'initializer', 'reinit')
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, 'door', 'reset')
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, 'condition', 'reset')
	get_tree().call_group_flags(SceneTree.GROUP_CALL_REALTIME, 'reseter', 'reset')
	
	yield(get_tree().create_timer(.25), 'timeout')
	
	
	FadeInOuter.fade_in(1.2)
	
	controller.use_custom_input(input)
	
	collision.set_deferred('disabled', false)
	
	_dying = false







