extends Sprite2D
@onready var lamplight: PointLight2D = $lamplight
@onready var lamplightminor: PointLight2D = $lamplightminor
@onready var fire_gpu_partcles: GPUParticles2D = $FireGPUPartcles
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"
@onready var directional_light_2d: DirectionalLight2D = $DirectionalLight2D
@onready var house: House = $"../../House"
@onready var clink_stream_player: AudioStreamPlayer = $"../ClinkStreamPlayer"

@onready var lights_energy = 3.0

func _on_lampcollision_area_entered(area: Area2D) -> void:
	print(house)
	animation_player.stop()
	animation_player.play("lamp_hit")
	if area is BulletModule:
		area.destroy()
		lamplight.enabled = !lamplight.enabled
		lamplightminor.enabled = !lamplightminor.enabled
		directional_light_2d.enabled = !directional_light_2d.enabled
		var tween = get_tree().create_tween()
		tween.tween_property(directional_light_2d, "energy", 0.15, 1).from(0.0)
		fire_gpu_partcles.emitting = !fire_gpu_partcles.emitting
		clink_stream_player.pitch_scale = randf_range(0.5, 0.8)
		clink_stream_player.play()
		if lamplight.enabled == true:
			house.lamps_lighted += 1 
		if lamplight.enabled == false:
			house.lamps_lighted -= 1 
		
#func _process(_delta: float) -> void:
	#if directional_light_2d.enabled == true:
		#var tween = get_tree().create_tween()
		#tween.tween_property(directional_light_2d, "energy", 0.1, 1).from(0.0)
