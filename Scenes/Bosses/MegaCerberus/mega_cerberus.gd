extends CharacterBody2D

var implements = [Interface.Mob, Interface.Damageable]

@export var behaviour_module: MobBehaviourModule
@export var hit_flash_shader: ShaderMaterial
@export var bullet: PackedScene

@onready var hit_flash_animation = $HitFlashAnimPlayer
@onready var heads = [$Head1, $Head2, $Head3]
var audio_track: = preload("res://Sounds/dogcrying1.mp3")
var audio_track2: = preload("res://Sounds/dogcrying2.mp3")
const HEAD1_POSITION_X_ABSOLUTE = 54
const HEAD2_POSITION_X_ABSOLUTE = 46
const HEAD3_POSITION_X_ABSOLUTE = 10

func _physics_process(_delta: float) -> void:
	behaviour_module.handle_movement()

func _process(_delta: float) -> void:
	behaviour_module.handle_sprite_flip()
	$Head1.position.x = -HEAD1_POSITION_X_ABSOLUTE if velocity.x < 0 else HEAD1_POSITION_X_ABSOLUTE
	$Head2.position.x = -HEAD2_POSITION_X_ABSOLUTE if velocity.x < 0 else HEAD2_POSITION_X_ABSOLUTE
	$Head3.position.x = -HEAD3_POSITION_X_ABSOLUTE if velocity.x < 0 else HEAD3_POSITION_X_ABSOLUTE
	
func take_damage(damage: float):
	$BloodParticles.emitting = true
	hit_flash_animation.play("hit_flash")
	behaviour_module.handle_take_damage(damage)
	
func _on_mob_cooldown_timeout() -> void:
	var bullet = bullet.instantiate()
	bullet.global_position = heads.pick_random().global_position
	get_parent().add_child(bullet)

func _on_cerberus_health_module_health_depleted() -> void:
	## GAMBIARRA
	var audio_options = [audio_track, audio_track2]
	var stream_player = AudioStreamPlayer.new()
	stream_player.stream = audio_options.pick_random()
	stream_player.pitch_scale = randf_range(0.7, 1.4)
	stream_player.autoplay = true
	get_parent().add_child(stream_player)
	
	$CollisionShape2D.set_deferred("disabled", true)
	$BloodParticles.emitting = true
	hit_flash_animation.connect("animation_finished", die_after_anim_finished)
	hit_flash_animation.play_backwards("hit_flash")
	EventBus.mega_cerberus_is_dead.emit()

func die_after_anim_finished(_anim_name):
	queue_free()
