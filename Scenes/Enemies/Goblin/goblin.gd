extends CharacterBody2D

var implements = [Interface.Mob, Interface.Damageable]

@export var behaviour_module: MobBehaviourModule

## Pick random animation (used as variations of Goblins).
func _ready() -> void:
	var goblin_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = goblin_types.pick_random()
	$AnimatedSprite2D.play()
	EventBus.enemy_died.connect(_on_enemy_died_received)

func _physics_process(_delta: float) -> void:
	behaviour_module.handle_movement()

func _process(_delta: float) -> void:
	behaviour_module.handle_sprite_flip()

func take_damage(damage: float):
	$BloodParticles.emitting = true
	behaviour_module.damage_squish(0.2, 0.1, Tween.TRANS_BOUNCE)
	behaviour_module.damage_knockback(25)
	behaviour_module.handle_take_damage(damage)

func _on_enemy_died_received(_self: MobBehaviourModule) -> void:
	if self.behaviour_module != _self:
		return

	$BloodParticles.emitting = true
	self.queue_free()
