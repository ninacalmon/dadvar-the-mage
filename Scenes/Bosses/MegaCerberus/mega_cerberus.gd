extends CharacterBody2D
class_name MegaCerberus

var implements = [Interface.Mob, Interface.Damageable]

@export var behaviour_module: MobBehaviourModule
@export var bullet: PackedScene
@export var house_key: PackedScene

@onready var health_module: HealthModule = $Behaviour/HealthModule
@onready var heads = [$Head1, $Head2, $Head3]
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const HEAD1_POSITION_X_ABSOLUTE = 54
const HEAD2_POSITION_X_ABSOLUTE = 46
const HEAD3_POSITION_X_ABSOLUTE = 10
const SHOULD_NOT_DESPAWN = true

@onready var boss_health_bar: HealthBar = get_tree().get_first_node_in_group(Global.GROUPS_DIC[Global.Groups.BOSS_HEALTH_BAR])

func _ready():
	EventBus.enemy_died.connect(_on_enemy_died_received)
	boss_health_bar.set_health_bar_target(self)
	boss_health_bar.show()

func _physics_process(_delta: float) -> void:
	behaviour_module.handle_movement()

func _process(_delta: float) -> void:
	$Head1.position.x = -HEAD1_POSITION_X_ABSOLUTE if velocity.x < 0 else HEAD1_POSITION_X_ABSOLUTE
	$Head2.position.x = -HEAD2_POSITION_X_ABSOLUTE if velocity.x < 0 else HEAD2_POSITION_X_ABSOLUTE
	$Head3.position.x = -HEAD3_POSITION_X_ABSOLUTE if velocity.x < 0 else HEAD3_POSITION_X_ABSOLUTE
	
func take_damage(damage: float):
	$BloodParticles.emitting = true
	behaviour_module.handle_take_damage(damage)
	
func _on_mob_cooldown_timeout() -> void:
	var bullet_instance = bullet.instantiate()
	bullet_instance.global_position = heads.pick_random().global_position
	get_parent().add_child(bullet_instance)

func _on_enemy_died_received(_self: MobBehaviourModule) -> void:
	if self.behaviour_module != _self:
		return

	var main_node = get_tree().get_first_node_in_group("Main")

	audio_stream_player.pitch_scale = randf_range(0.7, 1.4)
	audio_stream_player.play()
	audio_stream_player.reparent(main_node)
	audio_stream_player.finished.connect(func():audio_stream_player.queue_free())

	$BloodParticles.emitting = true
	EventBus.mega_cerberus_is_dead.emit()

	var house_key_instance = house_key.instantiate()
	house_key_instance.global_position = self.global_position
	main_node.add_child(house_key_instance)

	boss_health_bar.hide()
	self.queue_free()
