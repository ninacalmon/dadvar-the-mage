extends Node2D

func _ready() -> void:
	$CPUParticles2D.emitting = true
	CameraShake.apply_shake(15, 10)

	var audio_stream = $AudioStreamPlayer
	audio_stream.reparent(get_tree().get_first_node_in_group("Main"))
	audio_stream.finished.connect(func():
		audio_stream.queue_free()
	)
