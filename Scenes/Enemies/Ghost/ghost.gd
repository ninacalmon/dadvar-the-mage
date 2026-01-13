extends CharacterBody2D

@export var behaviour_module: MobBehaviourModule

var implements = [Interface.Mob, Interface.Damageable]

func _physics_process(_delta: float) -> void:
	behaviour_module.handle_movement()

func _process(_delta: float) -> void:
	behaviour_module.handle_sprite_flip()

func take_damage(damage: float):
	behaviour_module.handle_take_damage(damage)

#@export var movement_speed = 50
#@onready var player = get_tree().get_first_node_in_group("PlayerGroup")
#
#func _ready() -> void:
	#var mob_types = Array($AnimatedSprite2D.sprite_frames.get_animation_names())
	#$AnimatedSprite2D.animation = mob_types.pick_random()
	#$AnimatedSprite2D.play()
#
#func _physics_process(_delta: float) -> void:
	## point to Player and move towards it.
	#var direction = global_position.direction_to(player.global_position)
	#velocity = direction * movement_speed
	#move_and_slide()
	#
## sprite flipping h.
#func _process(_delta: float) -> void:
	#$AnimatedSprite2D.flip_h =  position.x > player.global_position.x
#
## despawn when out of screen.
#func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	#queue_free()
	#

func _on_ghost_health_module_health_depleted() -> void:
	var tween = get_tree().create_tween()
	$CollisionShape2D.set_deferred("disabled", true)
	tween.tween_property($AnimatedSprite2D, "modulate", Color(1, 1, 1, 0), 0.5)
	tween.tween_callback(self.queue_free)
