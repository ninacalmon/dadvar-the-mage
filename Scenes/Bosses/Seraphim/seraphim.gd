extends CharacterBody2D
class_name Seraphim

var implements = [Interface.Mob, Interface.Damageable]

@export var behaviour_module: MobBehaviourModule
@export var house_key: PackedScene

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var boss_health_bar: HealthBar = get_tree().get_first_node_in_group(Global.GROUPS_DIC[Global.Groups.BOSS_HEALTH_BAR])


const SHOULD_NOT_DESPAWN = true

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_died_received)
	boss_health_bar.set_health_bar_target(self)
	boss_health_bar.show()
	

func _physics_process(delta: float) -> void:
	behaviour_module.handle_movement(delta)

func take_damage(damage: float):
	$BloodParticles.emitting = true
	behaviour_module.damage_squish(0.2, 0.1, Tween.TRANS_BOUNCE)
	behaviour_module.damage_knockback(25)
	behaviour_module.handle_take_damage(damage)

func _on_enemy_died_received(_self: MobBehaviourModule) -> void:
	if self.behaviour_module != _self:
		return

	$BloodParticles.emitting = true
	boss_health_bar.hide()
	
	var main_node = get_tree().get_first_node_in_group("Main")

	var house_key_instance = house_key.instantiate()
	house_key_instance.global_position = self.global_position
	main_node.add_child(house_key_instance)

	self.queue_free()
