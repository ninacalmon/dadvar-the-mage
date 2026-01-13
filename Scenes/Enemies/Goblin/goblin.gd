extends CharacterBody2D

var implements = Interface.Damageable

@export var behaviour_module: MobBehaviourModule
@export var hit_flash_shader: ShaderMaterial

@onready var hit_flash_animation = $HitFlashAnimPlayer

var original_modulate

func _ready() -> void:
	var goblin_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = goblin_types.pick_random()
	$AnimatedSprite2D.play()
	original_modulate = $AnimatedSprite2D.modulate

func _physics_process(_delta: float) -> void:
	behaviour_module.handle_movement()

func _process(_delta: float) -> void:
	behaviour_module.handle_sprite_flip()
	
func take_damage(damage: float):
	var tween = get_tree().create_tween()
	#hit_flash_shader.set('shader_parameter/enable', true)
	#self.AnimatedSprite2D.material.set('shader_parameter/enable', true)
	#await tween.tween_property($AnimatedSprite2D, "modulate", Color(10000000, 10000000, 10000000, 1), 0.1)
	#await tween.tween_property($AnimatedSprite2D, "modulate", original_modulate, 0.1)
	$BloodParticles.emitting = true
	hit_flash_animation.play("hit_flash")
	behaviour_module.handle_take_damage(damage)

func _on_mob_behaviour_im_dead() -> void:
	queue_free()
