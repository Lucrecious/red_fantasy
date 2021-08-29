extends Node

const KnightFootstep := preload('res://assets/audio/sounds/footstep1_random_pitch.tres')
const KnightFootstep2 := preload('res://assets/audio/sounds/footstep2.wav')
const Slash1 := preload('res://assets/audio/sounds/slash1.wav')
const Stab1 := preload('res://assets/audio/sounds/stab1.wav')
const Swipe1 := preload('res://assets/audio/sounds/swipe1.wav')
const Land1 := preload('res://assets/audio/sounds/land1.wav')
const Jump1 := preload('res://assets/audio/sounds/jump1.wav')
const Roll1 := preload('res://assets/audio/sounds/roll1.wav')

const VolumeDB := {
	KnightFootstep : -15.0,
	KnightFootstep2 : -15.0,
	Slash1 : -15.0,
	Stab1 : -15.0,
	Swipe1 : -15.0,
	Land1 : -15.0,
	Jump1 : -15.0,
	Roll1 : -15.0,
}

var _stream_pool2d := []
var _stream_pool := []
var _in_use := {}

func _ready() -> void:
	for i in 7:
		_stream_pool2d.push_back(AudioStreamPlayer2D.new())
		_stream_pool.push_back(AudioStreamPlayer.new())

func play(sound_resource: AudioStream, parent: Node2D) -> void:
	var pool := []
	
	if parent:
		pool = _stream_pool2d
	else:
		pool = _stream_pool
	
	if pool.empty():
		return
	
	var stream_player := pool.pop_back() as Node
	stream_player.stream = sound_resource
	stream_player.volume_db = VolumeDB.get(sound_resource, 0)
	
	_in_use[stream_player] = true
	
	stream_player.stop()
	stream_player.connect('finished', self, '_on_sound_finished', [stream_player], CONNECT_ONESHOT)
	
	if not parent:
		add_child(stream_player)
	else:
		parent.add_child(stream_player)
	
	stream_player.play()

func _on_sound_finished(player: Node) -> void:
	player.get_parent().remove_child(player)
	
	_in_use.erase(player)
	
	if player is AudioStreamPlayer2D:
		_stream_pool2d.push_back(player)
	else:
		_stream_pool.push_back(player)
	
	player.stream = null








