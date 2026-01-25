extends Node

var camera: Camera2D
var shake_strength
var shake_decay
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	randomize()

func set_camera(cmr: Camera2D):
	self.camera = cmr

func apply_shake(shake_str: float, shake_dcay: float):
	self.shake_strength = shake_str
	self.shake_decay = shake_dcay

func _process(delta: float):
	if shake_strength and shake_strength > 0 and shake_decay:
		self.camera.offset = get_random_offset()
		self.shake_strength = lerpf(self.shake_strength, 0, self.shake_decay * delta)

func get_random_offset():
	return Vector2(
		rng.randf_range(-self.shake_strength, self.shake_strength), 
		rng.randf_range(-self.shake_strength, self.shake_strength)
	)
