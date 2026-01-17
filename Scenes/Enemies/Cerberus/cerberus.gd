extends CharacterBody2D

var implements = [Interface.Mob, Interface.Damageable]

@export var behaviour_module: MobBehaviourModule
@export var hit_flash_shader: ShaderMaterial

@onready var hit_flash_animation = $HitFlashAnimPlayer
var audio_track: = preload("res://Sounds/dogcrying1.mp3")
var audio_track2: = preload("res://Sounds/dogcrying2.mp3")


var colour0 = Color(1.0, 1.0, 1.0)
var colour1 = Color(0.7, 0.595, 0.595)
var colour2 = Color(0.923, 0.703, 0.703)
var colour3 = Color(1.317, 1.317, 1.317)

## Pick random sprint tint
func _ready() -> void:
	var colour_options = [colour0, colour0, colour0, colour1, colour2, colour3]
	$AnimatedSprite2D.modulate = colour_options.pick_random()

func _physics_process(_delta: float) -> void:
	behaviour_module.handle_movement()

func _process(_delta: float) -> void:
	behaviour_module.handle_sprite_flip()
	
func take_damage(damage: float):
	$BloodParticles.emitting = true
	hit_flash_animation.play("hit_flash")
	behaviour_module.handle_take_damage(damage)

func _on_cerberus_health_module_health_depleted() -> void:
	$CollisionShape2D.set_deferred("disabled", true)
	$BloodParticles.emitting = true
	hit_flash_animation.connect("animation_finished", die_after_anim_finished)
	hit_flash_animation.play_backwards("hit_flash")

func die_after_anim_finished(_anim_name):
	queue_free()
