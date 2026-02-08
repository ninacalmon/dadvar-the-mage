extends Node2D
class_name MobBehaviourModule

const HIT_SOUND = preload("uid://2oeqxeyg41fj")

@export var movement_speed: int
@export var acceleration: float
@export var damping: float = 0
@export var damage: float
@export var health_module: HealthModule
@export var vp_orb_scene: PackedScene


@export var mob: CharacterBody2D
@export var mob_collision_shape_array: Array[CollisionShape2D]
@export var mob_sprite: AnimatedSprite2D

@onready var player =  get_tree().get_first_node_in_group("PlayerGroup")
## THE HEALTH MODULE NEEDS TO BE SIBLING TO THE MOB BEHAVIOUR
## NOT THE BEST WAY TO DO THIS, MAYBE IMPROVE LATER
@onready var health_module_node = get_parent().get_node("HealthModule")
@onready var mob_screen_notifier = mob.get_node("VisibleOnScreenNotifier2D")
@onready var lifespan_timer: Timer = $LifespanTimer

var tick: int = 0
var original_mob_sprite_scale_x: float
var original_mob_sprite_scale_y: float
var time: int = 0
var direction_normalized_x: float

## ASSERT VARIABLES ON READY TO AVOID GETTING ERRORS THAT ARE NONSENSE
func _ready():
	self.original_mob_sprite_scale_x = self.mob_sprite.scale.x
	self.original_mob_sprite_scale_y= self.mob_sprite.scale.y

	health_module_node.connect("health_depleted", _on_health_module_health_depleted)
	if mob_screen_notifier:
		mob_screen_notifier.screen_exited.connect(_on_screen_exited)
		
	lifespan_timer.timeout.connect(self_despawn)
	lifespan_timer.start()
	
	if !acceleration:
		self.acceleration = self.movement_speed
	
	if !damping:
		self.damping = self.movement_speed


func _on_screen_exited():
	mob.queue_free()
	Global.CURRENT_MOBS_SPAWNED -= 1

func handle_movement(delta: float) -> void:
	## Verify if mob in the last X frames moved less than some limit. If this is true, try to move only after
	## x seconds.
	## Also, we can change the mob direction after X frames
	var direction = mob.global_position.direction_to(player.global_position)
	var target_velocity = direction * movement_speed
	
	##Accelerate toward target velocity
	mob.velocity = mob.velocity.move_toward(target_velocity, acceleration * delta)
	
	##Damping when close to target
	if mob.global_position.distance_squared_to(player.global_position) < 20000:
		mob.velocity = mob.velocity.move_toward(Vector2.ZERO, damping * delta)

	if mob.global_position.distance_squared_to(player.global_position) > 3:
		self.direction_normalized_x = sign(direction.x) if sign(direction.x) != 0 else 1
		mob_sprite.scale.x = self.direction_normalized_x

	mob.move_and_slide()

func handle_take_damage(damage_to_receive: float) -> void:
	
	var direction = mob.global_position.direction_to(player.global_position)
	var  mob_offset_sprite_y = get_sprite_texture().get_height()
	var mob_offset_to_front_x = -25 * direction.x

	NumberPopUp.create_damage_number_pop_up(damage_to_receive, mob.global_position - Vector2(mob_offset_to_front_x, mob_offset_sprite_y))
	var current_health = health_module.get_health()
	health_module.set_health(current_health - damage_to_receive)
	

	var audio_player := AudioStreamPlayer.new()
	audio_player.stream = HIT_SOUND
	audio_player.volume_db = randf_range(-20, -24)
	audio_player.pitch_scale = randf_range(-1.4, 1.4)
	audio_player.bus = Global.AUDIO_BUS_DIC[Global.AudioBus.SOUND_EFFECTS]

	get_tree().get_first_node_in_group("Main").add_child(audio_player)
	audio_player.play()
	self.play_hit_flash()
	
# drops xp orb
func _on_health_module_health_depleted() -> void:
	self.movement_speed = 0
	await death_dissolve().finished

	EventBus.enemy_died.emit(self)
	Global.CURRENT_MOBS_SPAWNED -= 1

	if vp_orb_scene:
		var vp_orb = vp_orb_scene.instantiate()
		vp_orb.position = get_parent().get_parent().position
		vp_orb.mob_hp = self.health_module.max_health
		var game_node = get_tree().get_first_node_in_group("YSortedLayerGroup")

		game_node.add_child(vp_orb)

func damage_squish(amount, duration, ease_mode):
	var squish_tween = get_tree().create_tween()
	squish_tween.tween_property(self.mob_sprite, "scale:x", self.original_mob_sprite_scale_x * self.direction_normalized_x - amount, duration).set_trans(ease_mode)
	squish_tween.parallel().tween_property(self.mob_sprite, "scale:y", self.original_mob_sprite_scale_y + amount/3, duration).set_trans(ease_mode)
	squish_tween.tween_property(self.mob_sprite, "scale:x", self.original_mob_sprite_scale_x * self.direction_normalized_x, duration).set_trans(ease_mode)
	squish_tween.parallel().tween_property(self.mob_sprite, "scale:y", self.original_mob_sprite_scale_y, duration).set_trans(ease_mode)

func damage_knockback(amount):
	mob.global_position = mob.global_position - mob.global_position.direction_to(player.global_position) * amount
	
func self_despawn():
	if mob.get("SHOULD_NOT_DESPAWN"):
		return

	await death_dissolve(0.8).finished

	Global.CURRENT_MOBS_SPAWNED -= 1
	mob.queue_free()
	
func get_sprite_texture() -> CompressedTexture2D:
	var mob_sprite_first_anim_frame = mob_sprite.sprite_frames.get_animation_names().get(0)
	var mob_first_anim_frame_texture: CompressedTexture2D = mob_sprite.sprite_frames.get_frame_texture(mob_sprite_first_anim_frame, 0)
	return mob_first_anim_frame_texture

func death_dissolve(time_to_disolve: float = 0.4) -> Tween:
	for mob_collision_shape in self.mob_collision_shape_array:
		mob_collision_shape.set_deferred("disabled", true)

	var tween = get_tree().create_tween()
	tween.tween_property(
		mob_sprite.material,
		"shader_parameter/dissolve_value",
		0.0,
		time_to_disolve
	).from(1.0)

	return tween

func play_hit_flash(duration := 0.06) -> void:
	mob_sprite.material.set_shader_parameter("hit_flash_enabled", true)
	await get_tree().create_timer(duration).timeout
	mob_sprite.material.set_shader_parameter("hit_flash_enabled", false)
