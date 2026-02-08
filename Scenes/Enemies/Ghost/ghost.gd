extends CharacterBody2D

@export var behaviour_module: MobBehaviourModule
@export var health_module: HealthModule
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var implements = [Interface.Mob, Interface.Damageable]

## Pick random animation (used as variations of Ghosts).
func _ready() -> void:
	var ghost_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = ghost_types.pick_random()
	$AnimatedSprite2D.play()
	EventBus.enemy_died.connect(_on_enemy_died_received)

func _physics_process(delta: float) -> void:
	behaviour_module.handle_movement(delta)

func take_damage(damage: float):
	$BloodParticles.emitting = true
	behaviour_module.damage_squish(0.2, 0.2, Tween.TRANS_BOUNCE)
	behaviour_module.damage_knockback(25)
	behaviour_module.handle_take_damage(damage)

func _on_enemy_died_received(_self: MobBehaviourModule) -> void:
	if self.behaviour_module != _self:
		return

	$BloodParticles.emitting = true
	self.queue_free()
