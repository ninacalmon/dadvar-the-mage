extends Area2D
class_name Player
signal player_death

#region Exports
@export_group("Modules")
@export var stats_module: StatsModule
@export var health_module: HealthModule

@export_group("Local Variables")
@export var speed = 400
@export var bullet: PackedScene
var cast_cooldown = 0

#@export_subgroup("Wobble")
#@export var frequency := 1.0
#@export var amplitude := PI * 0.25
#endregion

#region Spells and Upgrades
@export_subgroup("Spells and upgrades")
@export var projectile_spells: Array[EventSpell.ProjectileSpell] = []
@export var enemy_action_spells: Array[EventSpell.EnemyActionSpell] = []
@export var stats_spells: Array[EventSpell.StatsSpell] = []
@export var node_spells: Array[EventSpell.NodeSpell] = []
@export var timer_spells: Array[EventSpell.TimerSpell] = []
## MAYBE HAVE HERE A SPELL UPGRADES OR SOMETHING LIKE THIS WHICH ARE UPGRADES THAT
## ARE NOT EFFECTS ON THE BULLET
#endregion

#region On Ready Vars

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var hurt_box: CollisionShape2D = $HurtBox
@onready var wand_tip: Node2D = $"../WandTip"
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var vp_collector: Area2D = $VpCollector
@onready var vp_range: CollisionShape2D = $VpCollector/VpRange
@onready var hit_flash_animation: AnimationPlayer = $HitFlashAnimPlayer
@onready var magic_light: PointLight2D = $MagicLight
@onready var hit_flash_material: ShaderMaterial = player_sprite.material

#endregion

var audio_track: AudioStream = preload("res://Sounds/retro-game-shot-2-152053.mp3")
const WAND_TIP_POSITION_X_ABSOLUTE = 63

func start(pos):
	position = pos
	hit_flash_animation.play("hit_flash")
	show()
	hurt_box.disabled = false

	EventBus.new_spell_added.connect(add_new_spell)
	#self.add_new_spell(ProfaneBolt.new())
	#self.add_new_spell(OgresScent.new())
	#self.add_new_spell(VampiricGoblet.new())
	#self.add_new_spell(BoreasSwiftness.new())
	#self.add_new_spell(TitansSkin.new())
	#self.add_new_spell(YggdrasilTea.new())
	#self.add_new_spell(SoulPiercer.new())

## PUT THIS IN UTILS LATER!!!
#func wobble():
	#player_sprite.rotation = sin(Time.get_ticks_msec() * frequency) * amplitude

func take_damage(mob_behaviour: MobBehaviourModule = null, bullet_module: BulletModule = null):
	self.hit_flash_animation.play("hit_flash")
	var current_health = health_module.get_health()

	var damage_received = mob_behaviour.damage if mob_behaviour != null else bullet_module.damage

	var damage_to_take = damage_received * (100/(100 + self.stats_module.current_defense))

	self.health_module.set_health(current_health - damage_to_take)

func _physics_process(delta: float) -> void:
	cast_cooldown = max(cast_cooldown - delta, 0)
	if Input.is_action_just_pressed("shoot") and cast_cooldown <= 0:
		var bullet_instance = self.bullet.instantiate()
		var bullet_module = bullet_instance.bullet_module
		bullet_instance.global_position = wand_tip.position

		var spell_context = SpellContext.new()

		spell_context.bullet_module = bullet_module

		for projectile_spell in projectile_spells:
			projectile_spell.apply_spell(spell_context)

		NodeShake.apply_shake(player_sprite, 5, 20)
		
		magic_light.position = wand_tip.position 
		magic_light.texture_scale = randf_range(2.5, 3)
		magic_light.energy = randf_range(9, 13)
		magic_light.enabled = true
	
		var light_tween = get_tree().create_tween()
		light_tween.tween_property(magic_light, "energy", 0, stats_module.base_cast_cooldown)
		light_tween.parallel().tween_property(magic_light, "texture_scale", 0.8, stats_module.base_cast_cooldown)
		get_parent().add_child(bullet_instance)
		cast_cooldown = self.stats_module.current_cast_cooldown
	

#func _process(delta: float) -> void:
	#var velocity = Vector2.ZERO
	#if Input.is_action_pressed("Right"):
		#velocity.x += 1
	#if Input.is_action_pressed("Left"):
		#velocity.x -= 1
	#if Input.is_action_pressed("Down"):
		#velocity.y += 1
	#if Input.is_action_pressed("Up"):
		#velocity.y -= 1
#
	#if velocity.length() > 0:
		#player_sprite.animation = "idle"
		#player_sprite.flip_h = velocity.x < 0
#
		#wand_tip.position.x = -WAND_TIP_POSITION_X_ABSOLUTE if velocity.x < 0 else WAND_TIP_POSITION_X_ABSOLUTE
		#wobble()
		#velocity = velocity.normalized() * stats_module.current_move_speed
	#else:
		#player_sprite.animation = "idle"
		#player_sprite.rotation = 0
		#
	#position += velocity * delta # updating position.

	# Collision
func _on_body_entered(body: Node2D) -> void:
	var is_mob = Interface.node_implements_interface(body, Interface.Mob)
	if is_mob == true:
		var behaviour: MobBehaviourModule = body.behaviour_module
		self.take_damage(behaviour)

func _on_area_entered(area: Area2D) -> void:
	var node_mob_projectile = Interface.is_any_interface_implements_node(find_root_node(area), Interface.MobProjectile)
	var node_stat_modifier = Interface.is_any_interface_implements_node(find_root_node(area), Interface.StatsModifiers)

	if node_mob_projectile != null:
		var bullet_module: BulletModule = node_mob_projectile.bullet_module
		self.take_damage(null, bullet_module)

	if node_stat_modifier != null:
		var stat_modifier: StatModifier = node_stat_modifier.stat_modifier
		assert(stat_modifier is StatModifier, "Stat modifier received is invalid. Check if the stat modifier is correctly defined on the entity instance")
		stats_module.add_modifier(stat_modifier)


func _on_player_health_health_depleted() -> void:
	var stream_player = AudioStreamPlayer.new()
	stream_player.stream = audio_track
	stream_player.pitch_scale = randf_range(0.2, 0.3)

	get_parent().add_child(stream_player)

	var tween = get_tree().create_tween()
	hurt_box.set_deferred("disabled", true)

	self.hit_flash_animation.play_backwards("hit_flash")
	tween.tween_callback(stream_player.play)
	tween.parallel().tween_property(player_sprite, "scale", Vector2(1, 0.06), 1)

	tween.tween_callback(player_death.emit)

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

func add_new_spell(spell: EventSpell):
	match spell.get_event_spell_type():
		EventSpell.EventSpellType.PROJECTILE:
			self.projectile_spells.append(spell)
		EventSpell.EventSpellType.ENEMY_ACTION:
			self.enemy_action_spells.append(spell)

			var spell_context = SpellContext.new()
			spell_context.player = self

			spell.apply_spell(spell_context)
		EventSpell.EventSpellType.STATS_SPELL:
			self.stats_spells.append(spell)

			var spell_context = SpellContext.new()
			spell_context.stats_module = self.stats_module
			spell_context.health_module = self.health_module

			spell.apply_spell(spell_context)
		EventSpell.EventSpellType.NODE_SPELL:
			self.node_spells.append(spell)

			var spell_context = SpellContext.new()
			spell_context.player = self

			spell.apply_spell(spell_context)
		EventSpell.EventSpellType.TIMER_SPELL:
			self.timer_spells.append(spell)

			var spell_context = SpellContext.new()
			spell_context.player = self

			spell.apply_spell(spell_context)
