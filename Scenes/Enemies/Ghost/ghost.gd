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
	behaviour_module.handle_take_damage(damage)

func _on_ghost_health_module_health_depleted() -> void:
	var tween = get_tree().create_tween()
	$CollisionShape2D.set_deferred("disabled", true)
	tween.tween_property($AnimatedSprite2D, "modulate", Color(1, 1, 1, 0), 0.2)
	tween.tween_callback(self.queue_free)
