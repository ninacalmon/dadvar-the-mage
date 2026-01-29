extends Node2D
class_name MobBehaviourModule

@export var movement_speed: int
@export var damage: float
@export var health_module: HealthModule
@export var vp_orb_scene: PackedScene

@export var mob: CharacterBody2D
@export var mob_sprite: AnimatedSprite2D
@onready var player =  get_tree().get_first_node_in_group("PlayerGroup")
## THE HEALTH MODULE NEEDS TO BE SIBLING TO THE MOB BEHAVIOUR
## NOT THE BEST WAY TO DO THIS, MAYBE IMPROVE LATER
@onready var health_module_node = get_parent().get_node("HealthModule")
@onready var mob_screen_notifier = mob.get_node("VisibleOnScreenNotifier2D")

## ASSERT VARIABLES ON READY TO AVOID GETTING ERRORS THAT ARE NONSENSE
func _ready():
	health_module_node.connect("health_depleted", _on_health_module_health_depleted)
	if mob_screen_notifier:
		mob_screen_notifier.screen_exited.connect(_on_screen_exited)

func _on_screen_exited():
	mob.queue_free()
	Global.CURRENT_MOBS_SPAWNED -= 1
	print("SCREEN EXITED!", Global.CURRENT_MOBS_SPAWNED)

func handle_movement() -> void:
	# point to Player and move towards it.
	var direction = mob.global_position.direction_to(player.global_position)
	mob.velocity = direction * movement_speed
	mob.move_and_slide()
	
func handle_sprite_flip() -> void:
	## Important to always reference the mob variable before, if not, Godot will understand that this is referencing the
	## Behaviour node position! (Which does not moves at all)
	#### CHAAAANGE THAT IS WRONG!!! This only flips the sprite, causing collision shape to me missaligned.
	#### We need to flip the whole mob node.
	mob_sprite.flip_h =  mob.global_position.x > player.global_position.x

func handle_take_damage(damage_to_receive: float) -> void:
	var current_health = health_module.get_health()
	health_module.set_health(current_health - damage_to_receive)
	
# drops xp orb
func _on_health_module_health_depleted() -> void:
	EventBus.enemy_died.emit(self)
	Global.CURRENT_MOBS_SPAWNED -= 1
	assert(vp_orb_scene != null, "Mob does not have a VP orb to drop defined")
	var vp_orb = vp_orb_scene.instantiate()
	vp_orb.position = get_parent().get_parent().position
	vp_orb.mob_hp = self.health_module.max_health
	var game_node = get_tree().get_current_scene()

	game_node.add_child(vp_orb)

func damage_squish(amount, duration, ease_mode):
	var original_scale_x = self.mob_sprite.scale.x
	var original_scale_y = self.mob_sprite.scale.y
	var squish_tween = get_tree().create_tween()
	squish_tween.tween_property(self.mob_sprite, "scale:x", original_scale_x - amount, duration).set_trans(ease_mode)
	squish_tween.parallel().tween_property(self.mob_sprite, "scale:y", original_scale_y + amount/3, duration).set_trans(ease_mode)
	squish_tween.tween_property(self.mob_sprite, "scale:x", original_scale_x, duration).set_trans(ease_mode)
	squish_tween.parallel().tween_property(self.mob_sprite, "scale:y", original_scale_y, duration).set_trans(ease_mode)

func damage_knockback(amount):
	mob.global_position = mob.global_position - mob.global_position.direction_to(player.global_position) * amount
