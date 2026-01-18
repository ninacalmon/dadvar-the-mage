extends Area2D
class_name Player
signal player_death

const WAND_TIP_POSITION_X_ABSOLUTE = 63

@export_group("Modules")
@export var stats_module: StatsModule
@export var health_module: HealthModule

@export_group("Local Variables")
@export var speed = 400
@export var bullet: PackedScene
@export var player_shoot_cooldown: float

@export_subgroup("Wobble")
@export var frequency := 1.0
@export var amplitude := PI * 0.25

@export_subgroup("Spells and upgrades")
@export var projectile_spells: Array[EventSpell.ProjectileSpell]
## MAYBE HAVE HERE A SPELL UPGRADES OR SOMETHING LIKE THIS WHICH ARE UPGRADES THAT
## ARE NOT EFFECTS ON THE BULLET

var shoot_cooldown = 0

@onready var hit_flash_animation = $HitFlashAnimPlayer
var audio_track: AudioStream = preload("res://Sounds/retro-game-shot-2-152053.mp3")

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	

## PUT THIS IN UTILS LATER!!!
func wobble():
	$AnimatedSprite2D.rotation = sin(Time.get_ticks_msec() * frequency) * amplitude

func take_damage(mob_behaviour: MobBehaviourModule):
	hit_flash_animation.play("hit_flash")
	var current_health = health_module.get_health()
	health_module.set_health(current_health - mob_behaviour.damage)

func _physics_process(delta: float) -> void:
	shoot_cooldown = max(shoot_cooldown - delta, 0)
	if Input.is_action_just_pressed("shoot") and shoot_cooldown <= 0:
		var bullet_instance = self.bullet.instantiate()
		var bullet_module = bullet_instance.bullet_module
		bullet_instance.global_position = $WandTip.global_position
		## INSTANTIATING MANUALLY EVERY PROJECTILE SPELL AND PUTTING INTO THE CORRET ARRAY
		if projectile_spells.size() == 0:
			var soul_piercer_2 = SoulPiercer.new()
			soul_piercer_2.pierce_count = 2
			projectile_spells.append(soul_piercer_2)
			var soul_pierecer_4 = SoulPiercer.new()
			soul_pierecer_4.pierce_count = 4
			projectile_spells.append(soul_pierecer_4)

		var spell_context = SpellContext.new()

		spell_context.bullet_module = bullet_module

		for projectile_spell in projectile_spells:
			projectile_spell.apply_spell(spell_context)

		get_parent().add_child(bullet_instance)

		shoot_cooldown = player_shoot_cooldown

func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("Right"):
		velocity.x += 1
	if Input.is_action_pressed("Left"):
		velocity.x -= 1
	if Input.is_action_pressed("Down"):
		velocity.y += 1
	if Input.is_action_pressed("Up"):
		velocity.y -= 1

	if velocity.length() > 0:
		$AnimatedSprite2D.animation = "idle"
		$AnimatedSprite2D.flip_h = velocity.x < 0

		$WandTip.position.x = -WAND_TIP_POSITION_X_ABSOLUTE if velocity.x < 0 else WAND_TIP_POSITION_X_ABSOLUTE
		wobble()
		velocity = velocity.normalized() * stats_module.current_move_speed
	else:
		$AnimatedSprite2D.animation = "idle"
		$AnimatedSprite2D.rotation = 0
		
	position += velocity * delta # updating position.

	# Collision
func _on_body_entered(body: Node2D) -> void:
	var is_mob = Interface.node_implements_interface(body, Interface.Mob)
	if is_mob == true:
		var behaviour: MobBehaviourModule = body.behaviour_module
		take_damage(behaviour)

func _on_area_entered(area: Area2D) -> void:
	var node_mob_projectile = Interface.is_any_interface_implements_node(find_root_node(area), Interface.MobProjectile)
	var node_stat_modifier = Interface.is_any_interface_implements_node(find_root_node(area), Interface.StatsModifiers)

	if node_mob_projectile != null:
		var bullet_module: BulletModule = node_mob_projectile.bullet_module
		var current_health = health_module.get_health()
		health_module.set_health(current_health - bullet_module.damage)

	if node_stat_modifier != null:
		var stat_modifier: StatModifier = node_stat_modifier.stat_modifier
		assert(stat_modifier is StatModifier, "Stat modifier received is invalid. Check if the stat modifier is correctly defined on the entity instance")
		stats_module.add_modifier(stat_modifier)


func _on_player_health_health_depleted() -> void:
	## GAMBIARRA e não funciona ainda por causa da "morte" do player, mas será ajustado quando
	## a morte não resultar mais em restart instantaneo.
	var stream_player = AudioStreamPlayer.new()
	stream_player.stream = audio_track
	stream_player.pitch_scale = randf_range(0.8, 1.2)
	stream_player.autoplay = true
	get_parent().add_child(stream_player)
	
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	player_death.emit()

## Helper to find root of the node passed in
func find_root_node(node: Node) -> Node:
	# Find topmost parent of this scene instance
	var root = node

	while root.get_parent():
		## If scene tree only has root node, the root node returned is game
		## which should not happen. When scene tree has more than one node
		## it returns correctly the root node for the scene
		## NEED TO FIX IT LATER! UNTIL THEN, DO NOT USE AREA2D AS ROOT NODE
		#print("root:", root, "owner:", root.get_owner(), "parent owner:", root.get_parent().get_owner())

		if root.get_parent().get_owner() != root.get_owner():
			root = root.get_parent()
			break
		root = root.get_parent()

	return root
