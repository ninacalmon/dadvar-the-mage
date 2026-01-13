extends Node2D
class_name MobBehaviourModule
signal im_dead

@export var movement_speed: int
@export var damage: float
@export var health: float = 100

@export var mob: CharacterBody2D
@export var mob_sprite: AnimatedSprite2D
@onready var player =  get_tree().get_first_node_in_group("PlayerGroup")

func handle_movement() -> void:
	# point to Player and move towards it.
	var direction = mob.global_position.direction_to(player.global_position)
	mob.velocity = direction * movement_speed
	mob.move_and_slide()
	
func handle_sprite_flip() -> void:
	## Important to always reference the mob variable before, if not, Godot will understand that this is referencing the
	## Behaviour node position! (Which does not moves at all)
	mob_sprite.flip_h =  mob.global_position.x > player.global_position.x

func handle_take_damage(damage: float) -> void:
	self.health -= damage
	if (self.health <= 0):
		im_dead.emit()
