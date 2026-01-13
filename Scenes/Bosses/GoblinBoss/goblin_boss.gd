extends CharacterBody2D

var implements = [Interface.Mob, Interface.Damageable]

@export var behaviour_module: MobBehaviourModule

func _physics_process(_delta: float) -> void:
	behaviour_module.handle_movement()

func _process(_delta: float) -> void:
	behaviour_module.handle_sprite_flip()

func take_damage(damage: float):
	$BloodParticles.emitting = true
	behaviour_module.handle_take_damage(damage)

func _on_goblin_boss_health_module_health_depleted() -> void:
	queue_free()
