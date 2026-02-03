extends CharacterBody2D

var implements = [Interface.Mob, Interface.Damageable]

@export var behaviour_module: MobBehaviourModule

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var audio_track: AudioStream = preload("res://Sounds/witch-laugh-256450.mp3")

func _ready():
	EventBus.enemy_died.connect(_on_enemy_died_received)

func _physics_process(_delta: float) -> void:
	behaviour_module.handle_movement()

func _process(_delta: float) -> void:
	behaviour_module.handle_sprite_flip()

func take_damage(damage: float):
	$BloodParticles.emitting = true
	behaviour_module.damage_squish(0.2, 0.1, Tween.TRANS_BOUNCE)
	behaviour_module.damage_knockback(25)
	behaviour_module.handle_take_damage(damage)

func _on_enemy_died_received(_self: MobBehaviourModule) -> void:
	if self.behaviour_module != _self:
		return

	audio_stream_player.pitch_scale = randf_range(0.95, 1.1)
	audio_stream_player.play()
	audio_stream_player.reparent(get_tree().get_first_node_in_group("Main"))
	audio_stream_player.finished.connect(func(): audio_stream_player.queue_free())

	$BloodParticles.emitting = true

	self.queue_free()
