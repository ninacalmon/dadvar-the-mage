extends CharacterBody2D

var implements = [Interface.Mob, Interface.Damageable]

@export var behaviour_module: MobBehaviourModule
@export var health_module: HealthModule

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: CollisionShape2D = $Hitbox
@onready var stone_particles: CPUParticles2D = $StoneParticles
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D
@onready var hit_flash_animation = $HitFlashAnimPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	animated_sprite_2d.play("default")
	animated_sprite_2d.animation_changed.connect(_on_gargoyle_animation_changed)

func _physics_process(_delta: float) -> void:
	behaviour_module.handle_movement()

func _process(_delta: float) -> void:
	behaviour_module.handle_sprite_flip()
	
func take_damage(damage: float):
	stone_particles.emitting = true
	hit_flash_animation.play("hit_flash")
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
		3:
			if animated_sprite_2d.animation != "broken2":
				animated_sprite_2d.play("broken2")

func _on_gargoyle_animation_changed():
	audio_stream_player.play()

func _on_gargoyle_health_module_health_depleted() -> void:
	hitbox.set_deferred("disabled", true)
	stone_particles.emitting = true
	hit_flash_animation.connect("animation_finished", die_after_anim_finished)
	hit_flash_animation.play_backwards("hit_flash")

	audio_stream_player.play()
	audio_stream_player.reparent(get_tree().get_first_node_in_group("Main"))
	audio_stream_player.finished.connect(func(): queue_free())

func die_after_anim_finished(_anim_name):
	queue_free()
