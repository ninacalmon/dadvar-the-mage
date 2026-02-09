extends Node2D

@onready var explosion_gpu_partcles: GPUParticles2D = $ExplosionGPUPartcles
@onready var fire_gpu_partcles: GPUParticles2D = $FireGPUPartcles

func _ready():
	self.explosion_gpu_partcles.emitting = true
	await get_tree().process_frame
	self.explosion_gpu_partcles.emitting = false
	self.fire_gpu_partcles.emitting = true
	await get_tree().process_frame
	self.fire_gpu_partcles.emitting = false
