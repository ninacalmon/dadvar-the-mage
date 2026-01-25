extends Node2D

func _ready() -> void:
	$Sprite2D.scale.x = randi_range(1, -1)
	$CPUParticles2D.emitting = true
