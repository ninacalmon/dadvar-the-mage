extends Camera2D

var desired_offset: Vector2
var min_offset: int = -80
var max_offset: int = 80
@onready var player: CharacterBody2D = %player

func _ready():
	CameraShake.set_camera(self)
	
func _process(_delta):
	desired_offset = (get_global_mouse_position() - self.position) * 0.5
	desired_offset.x = clamp(desired_offset.x, min_offset, max_offset)
	desired_offset.y =  clamp(desired_offset.y, min_offset / 2.0, max_offset / 2.0)
	
	self.global_position = player.global_position + desired_offset
