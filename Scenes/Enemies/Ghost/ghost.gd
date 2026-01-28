extends CharacterBody2D

@export var behaviour_module: MobBehaviourModule

var implements = [Interface.Mob, Interface.Damageable]

## Pick random animation (used as variations of Ghosts).
func _ready() -> void:
	var ghost_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = ghost_types.pick_random()
	$AnimatedSprite2D.play()

func _physics_process(_delta: float) -> void:
	behaviour_module.handle_movement()

func _process(_delta: float) -> void:
	behaviour_module.handle_sprite_flip()

func take_damage(damage: float):
	$BloodParticles.emitting = true
	behaviour_module.damage_squish(0.2, 0.2, Tween.TRANS_BOUNCE)
	behaviour_module.damage_knockback(25)
	behaviour_module.handle_take_damage(damage)

func _on_ghost_health_module_health_depleted() -> void:
	$BloodParticles.emitting = true
	$CollisionShape2D.set_deferred("disabled", true)
	self.queue_free()
