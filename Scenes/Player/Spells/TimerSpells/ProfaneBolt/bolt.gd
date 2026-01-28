extends Node2D
const TIME_TO_SHAKE = 0.6

func _ready() -> void:
	$CPUParticles2D.emitting = true
	CameraShake.apply_shake(7, TIME_TO_SHAKE)

	var audio_stream = $AudioStreamPlayer
	audio_stream.reparent(get_tree().get_first_node_in_group("Main"))
	audio_stream.finished.connect(func():
		audio_stream.queue_free()
	)

	var particles = $CPUParticles2D
	particles.reparent(get_tree().get_first_node_in_group("Main"))
	particles.finished.connect(func():
		particles.queue_free()
	)
