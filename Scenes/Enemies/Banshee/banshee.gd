extends CharacterBody2D

const EXPLOSION_GPU_PARTICLES = preload("uid://v4mgn5rali81")

@export var behaviour_module: MobBehaviourModule

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var explosion_range: Area2D = $ExplosionRange
@onready var explosion_timer: Timer = $ExplosionTimer

@onready var audio_scream_player: AudioStreamPlayer = $Audios/AudioScreamPlayer
@onready var explosion_audio_player: AudioStreamPlayer = $Audios/ExplosionAudioPlayer

@onready var visible_on_screen_scream: VisibleOnScreenNotifier2D = $VisibleOnScreenScream

var player: Area2D
var implements = [Interface.Mob, Interface.Damageable]
var explosion_tween: Tween
var has_already_screamed_on_screen = false

func _ready() -> void:
	explosion_range.area_entered.connect(on_banshee_explosion_range_area_entered)
	explosion_range.area_exited.connect(on_banshee_explosion_range_area_exited)
	explosion_timer.timeout.connect(explode)
	visible_on_screen_scream.screen_entered.connect(_on_screen_scream_entered)
	EventBus.enemy_died.connect(_on_enemy_died_received)

func _physics_process(delta: float) -> void:
	behaviour_module.handle_movement(delta)

func _on_screen_scream_entered():
	if has_already_screamed_on_screen:
		return

	audio_scream_player.play()
	has_already_screamed_on_screen = true

func take_damage(damage: float):
	$BloodParticles.emitting = true
	behaviour_module.damage_squish(0.2, 0.2, Tween.TRANS_BOUNCE)
	behaviour_module.damage_knockback(25)
	behaviour_module.handle_take_damage(damage)

func on_banshee_explosion_range_area_entered(area: Area2D):
	if area.is_in_group("PlayerGroup"):
		audio_scream_player.play()
		explosion_timer.start()

		explosion_tween = get_tree().create_tween()
		explosion_tween.tween_property(self, "modulate", Color(1.317, 0.0, 0.0), explosion_timer.wait_time)
		
func on_banshee_explosion_range_area_exited(area: Area2D):
	if area.is_in_group("PlayerGroup"):
		if explosion_timer.time_left > explosion_timer.wait_time / 2:
			explosion_timer.stop()
			explosion_tween.kill()

			explosion_tween = get_tree().create_tween()
			explosion_tween.tween_property(self, "modulate", Color(1, 1, 1), 1)


func explode():
	self.behaviour_module.damage = 50
	self.behaviour_module.movement_speed = 0
	collision_shape_2d.scale = Vector2(30, 3)

	explosion_tween = get_tree().create_tween()
	explosion_tween.tween_property(self, "modulate", Color(18.892, 0.0, 0.0), 0.2)
	
	var main_node = get_tree().get_first_node_in_group("Main")
	explosion_audio_player.play()
	explosion_audio_player.reparent(main_node)
	explosion_audio_player.finished.connect(func(): explosion_audio_player.queue_free())

	self.spawn_explosion_particles()
	explosion_tween.tween_callback(self.queue_free)

func spawn_explosion_particles():
	var explosion_particles: GPUParticles2D = EXPLOSION_GPU_PARTICLES.instantiate()
	explosion_particles.global_position = animated_sprite_2d.global_position
	explosion_particles.emitting = true

	var main_node = get_tree().get_first_node_in_group("Main")
	main_node.add_child(explosion_particles)
	explosion_particles.finished.connect(func(): explosion_particles.queue_free())

func _on_enemy_died_received(_self: MobBehaviourModule) -> void:
	if self.behaviour_module != _self:
		return

	$BloodParticles.emitting = true
	self.queue_free()
