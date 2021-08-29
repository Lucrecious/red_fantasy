class_name SubComponent_SoundTrigger
extends Node

export(String) var sound_name := ''

func play(_1=null, _2=null, _3=null, _4=null, _5=null, _6=null) -> void:
	var sound_player := get_parent() as Component_SoundPlayer
	if not sound_player:
		return
	
	sound_player.play(sound_name)
