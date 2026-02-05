extends CharacterBody2D

var implements = [Interface.Mob, Interface.Damageable]

@export var behaviour_module: MobBehaviourModule
@export var goblilings: PackedScene
@onready var spawn_area: Area2D = $SpawnArea
@onready var spawn_area_shape: CollisionShape2D = $SpawnArea/SpawnAreaShape
@onready var goblin_magic_particles: CPUParticles2D = $GoblinMagicParticles
@onready var goblin_magic_particles_2: CPUParticles2D = $GoblinMagicParticles2
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hand_1: Node2D = $AnimatedSprite2D/Hand1
@onready var hand_2: Node2D = $AnimatedSprite2D/Hand2

@onready var spawn_minions_rate: Timer = $SpawnMinionsRate
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
var audio_track: AudioStream = preload("res://Sounds/witch-laugh-256450.mp3")

func _ready():
	EventBus.enemy_died.connect(_on_enemy_died_received)
	spawn_minions_rate.timeout.connect(_on_spawn_minions_timeout)
	
func _on_spawn_minions_timeout():
	## The offset returned is locally applied because the root node has offset of 1.5
	var local_offset = get_local_random_spawn_offset()
	## this line here turns the local_offset into global_offset by applying global_transform on it
	var global_spawn_pos = spawn_area.global_transform * local_offset
	spawn_minion(goblilings, global_spawn_pos)
	
func spawn_minion(minion_to_spawn, spawn_position):
	if Global.CURRENT_MOBS_SPAWNED >= Global.MAXIMUM_MOBS_TO_SPAWN:
		return

	var minion = minion_to_spawn.instantiate()
	minion.is_gobliling = true
	minion.global_position = spawn_position

	get_tree().get_first_node_in_group("YSortedLayerGroup").add_child(minion)

	Global.CURRENT_MOBS_SPAWNED += 1
	self.goblin_magic_particles.global_position = hand_1.global_position
	self.goblin_magic_particles_2.global_position = hand_2.global_position
	self.goblin_magic_particles.emitting = true
	self.goblin_magic_particles_2.emitting = true
	
func get_local_random_spawn_offset() -> Vector2:
	var circle: CircleShape2D = spawn_area_shape.shape
	
	var angle := randf() * TAU
	var distance := sqrt(randf()) * circle.radius

	var offset := Vector2(
			cos(angle),
			sin(angle)
		) * distance

	return offset

func _physics_process(_delta: float) -> void:
	pass
	behaviour_module.handle_movement()

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
