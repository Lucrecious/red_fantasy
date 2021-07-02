extends AnimatedSprite


func _ready():
	connect('animation_finished', self, 'queue_free')
	
	frame = 0
	playing = true
