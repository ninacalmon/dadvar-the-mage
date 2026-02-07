extends Sprite2D
@onready var lamplight: PointLight2D = $lamplight
@onready var lamplightminor: PointLight2D = $lamplightminor
@onready var fire_gpu_partcles: GPUParticles2D = $FireGPUPartcles
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

@onready var lights_energy = 3.0

func _on_lampcollision_area_entered(area: Area2D) -> void:
	animation_player.stop()
	animation_player.play("lamp_hit")
	if area is BulletModule:
		lamplight.enabled = !lamplight.enabled
		lamplightminor.enabled = !lamplightminor.enabled
		fire_gpu_partcles.emitting = !fire_gpu_partcles.emitting
		
func _process(_delta: float) -> void:
	if lamplight.enabled == true:
		light_flicker()

func light_flicker():
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	tween.tween_property(lamplight, "energy", lights_energy / 5, 0.5)
	tween.tween_property(lamplightminor, "energy", lights_energy / 5, 0.5)
	tween.set_parallel(false)
	tween.tween_property(lamplight, "energy", lights_energy, 0.5)
	tween.tween_property(lamplightminor, "energy", lights_energy, 0.5)
