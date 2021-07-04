class_name CameraBox_Game
extends Area2D

enum Side {
	Top = 0x1,
	Bottom = 0x2,
	Left = 0x4,
	Right = 0x8,
}

export(Side, FLAGS) var open_sides := 0

export(int, LAYERS_2D_PHYSICS) var _collision

func _ready() -> void:
	collision_layer = _collision
	collision_mask = _collision
