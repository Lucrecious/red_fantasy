class_name Component_SoundPlayer
extends Node2D

export(bool) var _use_2d := true

export(bool) var _use_wait_interval := true
export(int, 0, 100000) var _wait_interval_ms := 100

const _map := {
	KnightFootstep = Sound.KnightFootstep,
	KnightFootstep2 = Sound.KnightFootstep2,
	Slash1 = Sound.Slash1,
	Stab1 = Sound.Stab1,
	Swipe1 = Sound.Swipe1,
	Land1 = Sound.Land1,
	Jump1 = Sound.Jump1,
	Roll1 = Sound.Roll1,
	Hit1 = Sound.Hit1,
	KnightHit = Sound.KnightHit,
	Footstep1 = Sound.Footstep1,
	Footstep2 = Sound.Footstep2,
	GolemClap = Sound.GolemClap,
	GolemDeath = Sound.GolemDeath,
	BossScream = Sound.BossScream,
}

var _sound_name_to_last_msec_played := {}

func play(sound_name: String) -> void:
	var last_msec_played := _sound_name_to_last_msec_played.get(sound_name, -_wait_interval_ms) as int
	if OS.get_ticks_msec() - last_msec_played < _wait_interval_ms:
		return
	
	_sound_name_to_last_msec_played[sound_name] = OS.get_ticks_msec()
	var sound := _map.get(sound_name, null) as AudioStream
	var parent := self if _use_2d else null
	Sound.play(sound, parent)
