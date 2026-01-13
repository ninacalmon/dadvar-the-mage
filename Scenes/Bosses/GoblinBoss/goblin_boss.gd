extends CharacterBody2D

var implements = Interface.Damageable

@export var behaviour_module: MobBehaviourModule

func _physics_process(_delta: float) -> void:
	behaviour_module.handle_movement()

func _process(_delta: float) -> void:
	behaviour_module.handle_sprite_flip()

func take_damage(damage: float):
	#var tween = get_tree().create_tween()
	$BloodParticles.emitting = true
	#hit_flash_animation.play("hit_flash")
	behaviour_module.handle_take_damage(damage)

func _on_mob_behaviour_im_dead() -> void:
	queue_free()
