extends Node

const Boss1 := preload('res://assets/audio/music/boss1.wav')
const Wind1 := preload('res://assets/audio/music/wind1.ogg')
const Forest := preload('res://assets/audio/music/forest_theme.wav')

var _current: AudioStream

func _ready() -> void:
	play(Forest)

func play(music: AudioStream) -> void:
	if not music:
		return
	
	if _current == music:
		return
	
	stop()
	
	_current = music
	
	var music_player := AudioStreamPlayer.new()
	music_player.bus = 'Music'
	music_player.volume_db = -15.0
	music_player.stream = music
	add_child(music_player)
	music_player.play()
	
	music_player.connect('finished', self, 'stop', [], CONNECT_ONESHOT)

func stop() -> void:
	var player := NodE.get_child(self, AudioStreamPlayer) as AudioStreamPlayer
	if not player:
		return
	
	_current = null
	
	player.stop()
	player.queue_free()




