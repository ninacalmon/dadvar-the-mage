extends Node

var node_to_shake: Node ## AnimatedSprite2D ou Sprite2D
var shake_strength
var shake_decay
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	randomize()

func apply_shake(sprite, shake_str: float, shake_dcay: float):
	self.node_to_shake = sprite
	self.shake_strength = shake_str
	self.shake_decay = shake_dcay

func _process(delta: float):
	if node_to_shake and shake_strength and shake_strength > 0 and shake_decay and shake_decay > 0:
		self.node_to_shake.position.x = get_random_offset().x
		self.shake_strength = lerpf(self.shake_strength, 0, self.shake_decay * delta)

func get_random_offset():
	return Vector2(
		rng.randf_range(-self.shake_strength, self.shake_strength), 
		rng.randf_range(-self.shake_strength, self.shake_strength)
	)
