extends Node2D

func _enter_tree() -> void:
	var mobs = [$GoblinBoss, $"Mega Cerberus", $Seraphim, $Banshee, $GargoyleBody2D, $Ghost, $Goblin, $Skeleton]
	for mob in mobs:
		mob.behaviour_module.is_shader_preload = true

func _ready() -> void:
	var explosion_gpu_partcles: GPUParticles2D = $ExplosionGPUPartcles
	explosion_gpu_partcles.emitting = true

	var fire_gpu_partcles: GPUParticles2D = $FireGPUPartcles
	fire_gpu_partcles.emitting = true

	var player_body_2d: CharacterBody2D = $PlayerBody2d
	var player_area: Player = $PlayerBody2d/PlayerArea

	player_body_2d.is_shader_preload = true
	player_area.is_shader_preload = true

	for i in range(3):
		await RenderingServer.frame_post_draw

	explosion_gpu_partcles.emitting = false
	fire_gpu_partcles.emitting = false

	self.queue_free()
