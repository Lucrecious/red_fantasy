extends Tabs


onready var _tree := $Tree as Tree

func _ready() -> void:
	_tree.create_item()
	_tree.hide_root = true
	_tree.columns = 2
	
	var camera_smooth := _tree.create_item()
	camera_smooth.set_text(0, 'Camera Smooth')
	camera_smooth.set_selectable(0, false)
	camera_smooth.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
	camera_smooth.set_checked(1, GameOptions.camera_smooth)
	camera_smooth.set_editable(1, true)
	camera_smooth.set_selectable(1, false)
	
	var camera_shake := _tree.create_item()
	camera_shake.set_text(0, 'Camera Shake')
	camera_shake.set_selectable(0, false)
	camera_shake.set_cell_mode(1, TreeItem.CELL_MODE_CHECK)
	camera_shake.set_checked(1, GameOptions.camera_shake)
	camera_shake.set_editable(1, true)
	camera_shake.set_selectable(1, false)
	
	_tree.connect('item_edited', self, '_on_item_edited')

func _on_item_edited() -> void:
	var edited := _tree.get_edited()
	if edited.get_text(0) == 'Camera Smooth':
		GameOptions.camera_smooth = edited.is_checked(1)
	elif edited.get_text(0) == 'Camera Shake':
		GameOptions.camera_shake = edited.is_checked(1)
	else:
		assert(false, 'fix this method ')


