extends Node2D
class_name MobBehaviourModule

const HIT_SOUND = preload("uid://2oeqxeyg41fj")

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
@onready var lifespan_timer: Timer = $LifespanTimer

var tick = 0
var original_mob_sprite_scale_x
var original_mob_sprite_scale_y
var time: int = 0

## ASSERT VARIABLES ON READY TO AVOID GETTING ERRORS THAT ARE NONSENSE
func _ready():
	self.original_mob_sprite_scale_x = self.mob_sprite.scale.x
	self.original_mob_sprite_scale_y= self.mob_sprite.scale.y

	health_module_node.connect("health_depleted", _on_health_module_health_depleted)
	if mob_screen_notifier:
		mob_screen_notifier.screen_exited.connect(_on_screen_exited)
		
	lifespan_timer.timeout.connect(self_despawn)
	lifespan_timer.start()


func _on_screen_exited():
	mob.queue_free()
	Global.CURRENT_MOBS_SPAWNED -= 1
	print("SCREEN EXITED!", Global.CURRENT_MOBS_SPAWNED)


func handle_movement() -> void:
	# point to Player and move towards it.
	## Verify if mob in the last X frames moved less than some limit. If this is true, try to move only after
	## x seconds.
	## Also, we can change the mob direction after X frames
	var direction = mob.global_position.direction_to(player.global_position)
	mob.velocity = direction * movement_speed
	mob.move_and_slide()

## This one works way better, but it does not check collisions because it is not using move_and_slide physics
## performance got from ~11ms to 0.79 ms on this method. Probably will have to work on this
## to handle mobs
#func handle_movement(delta) -> void:
	## point to Player and move towards it.
	#tick += 1
#
	#if tick % 6 == 0:
		#var direction = player.global_position - mob.global_position
		##var direction = mob.global_position.direction_to(player.global_position)
		#mob.velocity = direction.normalized() * movement_speed
	#
	#mob.position += mob.velocity * delta
	
func handle_sprite_flip() -> void:
	## Important to always reference the mob variable before, if not, Godot will understand that this is referencing the
	## Behaviour node position! (Which does not moves at all)
	#### CHAAAANGE THAT IS WRONG!!! This only flips the sprite, causing collision shape to me missaligned.
	#### We need to flip the whole mob node.
	if mob.global_position.distance_squared_to(player.global_position) > 3:
		mob_sprite.flip_h =  mob.global_position.x >= player.global_position.x

func handle_take_damage(damage_to_receive: float) -> void:
	
	var direction = mob.global_position.direction_to(player.global_position)
	var mob_sprite_first_anim_frame = mob_sprite.sprite_frames.get_animation_names().get(0)
	var mob_first_anim_frame_texture = mob_sprite.sprite_frames.get_frame_texture(mob_sprite_first_anim_frame, 0)
	var mob_offset_sprite_y = mob_first_anim_frame_texture.get_size().y
	var mob_offset_to_front_x = -25 * direction.x

	NumberPopUp.create_damage_number_pop_up(damage_to_receive, mob.global_position - Vector2(mob_offset_to_front_x, mob_offset_sprite_y))
	var current_health = health_module.get_health()
	health_module.set_health(current_health - damage_to_receive)
	

	var audio_player := AudioStreamPlayer.new()
	audio_player.stream = HIT_SOUND
	audio_player.volume_db = randf_range(-20, -24)
	audio_player.pitch_scale = randf_range(-1.4, 1.4)

	get_tree().get_first_node_in_group("Main").add_child(audio_player)
	audio_player.play()
	
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
	var squish_tween = get_tree().create_tween()
	squish_tween.tween_property(self.mob_sprite, "scale:x", self.original_mob_sprite_scale_x - amount, duration).set_trans(ease_mode)
	squish_tween.parallel().tween_property(self.mob_sprite, "scale:y", self.original_mob_sprite_scale_y + amount/3, duration).set_trans(ease_mode)
	squish_tween.tween_property(self.mob_sprite, "scale:x", self.original_mob_sprite_scale_x, duration).set_trans(ease_mode)
	squish_tween.parallel().tween_property(self.mob_sprite, "scale:y", self.original_mob_sprite_scale_y, duration).set_trans(ease_mode)

func damage_knockback(amount):
	mob.global_position = mob.global_position - mob.global_position.direction_to(player.global_position) * amount
	
func self_despawn():
	print("TCHAU")
	Global.CURRENT_MOBS_SPAWNED -= 1
	mob.queue_free()
