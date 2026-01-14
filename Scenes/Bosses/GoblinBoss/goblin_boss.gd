extends CharacterBody2D

var implements = [Interface.Mob, Interface.Damageable]

@export var behaviour_module: MobBehaviourModule

@onready var hit_flash_animation = $HitFlashAnimPlayer
var audio_track: AudioStream = preload("res://Sounds/witch-laugh-256450.mp3")

func _physics_process(_delta: float) -> void:
	behaviour_module.handle_movement()

func _process(_delta: float) -> void:
	behaviour_module.handle_sprite_flip()

func take_damage(damage: float):
	$BloodParticles.emitting = true
	hit_flash_animation.play("hit_flash")
	behaviour_module.handle_take_damage(damage)

func _on_goblin_boss_health_module_health_depleted() -> void:
	## GAMBIARRA
	var stream_player = AudioStreamPlayer.new()
	stream_player.stream = audio_track
	stream_player.autoplay = true
	get_parent().add_child(stream_player)
	# $AudioStreamPlayer.playing = true
	$CollisionShape2D.set_deferred("disabled", true)
	$BloodParticles.emitting = true
	hit_flash_animation.connect("animation_finished", die_after_anim_finished)
	hit_flash_animation.play_backwards("hit_flash")

func die_after_anim_finished(_anim_name):
	queue_free()
