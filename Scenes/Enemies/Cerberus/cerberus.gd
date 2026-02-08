extends CharacterBody2D

var implements = [Interface.Mob, Interface.Damageable]

@export var behaviour_module: MobBehaviourModule

var colour0 = Color(1.0, 1.0, 1.0)
var colour1 = Color(0.7, 0.595, 0.595)
var colour2 = Color(0.923, 0.703, 0.703)
var colour3 = Color(1.317, 1.317, 1.317)

## Pick random sprint tint
func _ready() -> void:
	var colour_options = [colour0, colour0, colour0, colour1, colour2, colour3]
	$AnimatedSprite2D.modulate = colour_options.pick_random()
	EventBus.enemy_died.connect(_on_enemy_died_received)

func _physics_process(delta: float) -> void:
	behaviour_module.handle_movement(delta)

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
