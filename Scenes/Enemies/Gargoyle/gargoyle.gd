extends CharacterBody2D

var implements = [Interface.Mob, Interface.Damageable]

@export var behaviour_module: MobBehaviourModule
@export var health_module: HealthModule

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var stone_particles: CPUParticles2D = $StoneParticles
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	animated_sprite_2d.play("default")
	EventBus.enemy_died.connect(_on_enemy_died_received)

func _physics_process(_delta: float) -> void:
	behaviour_module.handle_movement()

func _process(_delta: float) -> void:
	behaviour_module.handle_sprite_flip()
	
func take_damage(damage: float):
	stone_particles.emitting = true
	behaviour_module.damage_squish(0.2, 0.1, Tween.TRANS_BOUNCE)
	behaviour_module.damage_knockback(10)

	## Adjust code here to deal the damage the player is really dealing - some gargoyle defense.
	## Need to calculate broken count addition correctly to avoid killing gargoyle before 3 stages
	var gargoylic_health_stage = self.health_module.get_max_health() / 3

	behaviour_module.handle_take_damage(damage)
	var current_health = self.health_module.get_health()
	## Plus one because floor will make 2.9 (which should be 3 stage) be rounded to 2
	## and cast to integer just to avoid having 3.0, 2.0, etc... on match statement
	var current_stage = int(floor(current_health / gargoylic_health_stage)) + 1

	match current_stage:
		3:
			if animated_sprite_2d.animation != "default":
				animated_sprite_2d.play("default")
		2:
			if animated_sprite_2d.animation != "broken":
				animated_sprite_2d.play("broken")
				audio_stream_player.play()
		1:
			if animated_sprite_2d.animation != "broken2":
				animated_sprite_2d.play("broken2")
				audio_stream_player.play()

func _on_enemy_died_received(_self: MobBehaviourModule) -> void:
	if self.behaviour_module != _self:
		return

	stone_particles.emitting = true
	audio_stream_player.play()
	audio_stream_player.reparent(get_tree().get_first_node_in_group("Main"))
	audio_stream_player.finished.connect(func(): audio_stream_player.queue_free())

	self.queue_free()
