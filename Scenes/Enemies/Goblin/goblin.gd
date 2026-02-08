extends CharacterBody2D

var implements = [Interface.Mob, Interface.Damageable]
var is_gobliling: bool = false

@export var behaviour_module: MobBehaviourModule
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

## Pick random animation (used as variations of Goblins).
func _ready() -> void:
	var goblin_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	$AnimatedSprite2D.animation = goblin_types.pick_random()
	$AnimatedSprite2D.play()
	EventBus.enemy_died.connect(_on_enemy_died_received)
	if is_gobliling == true:
		self.animated_sprite_2d.material.set_shader_parameter("dissolve_outline_color", Color(0.47, 0.82, 0.164))
		var tween = get_tree().create_tween()
		tween.tween_property(
		self.animated_sprite_2d.material,
		"shader_parameter/dissolve_value",
		1.0,
		1
		).from(0.0)
	

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
