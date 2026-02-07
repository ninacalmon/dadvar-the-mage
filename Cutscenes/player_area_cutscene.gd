extends Area2D
signal player_death

#region Exports
@export_group("Modules")
@export var stats_module: StatsModule
@export var health_module: HealthModule

@export_group("Local Variables")
@export var speed = 400
@export var bullet: PackedScene
var cast_cooldown: float = 0.5
var lazy_cast_cooldown: float = 2

#@export_subgroup("Wobble")
#@export var frequency := 1.0
#@export var amplitude := PI * 0.25
#endregion

#region Spells and Upgrades
@export_subgroup("Spells and upgrades")
@export var spells: Array[EventSpell] = []
#endregion

#region On Ready Vars

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite
@onready var hurt_box: CollisionShape2D = $HurtBox
@onready var wand_tip: Node2D = $"../WandTip"
@onready var magic_light: PointLight2D = $MagicLight

#endregion

var audio_track: AudioStream = preload("res://Sounds/retro-game-shot-2-152053.mp3")
var mobs_on_damage_range: Array[MobBehaviourModule] = []
const WAND_TIP_POSITION_X_ABSOLUTE = 63

func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(
		player_sprite.material,
		"shader_parameter/dissolve_value",
		1.0,
		2
	).from(0.0)
	self.show()
	self.hurt_box.disabled = false
	self.body_exited.connect(_on_body_exited)
	EventBus.new_spell_added.connect(add_new_spell)
	magic_light.position = wand_tip.position

	
	#self.add_new_spell(ProfaneBolt.new(), 1)
	#self.add_new_spell(OgresScent.new(), 1)
	#self.add_new_spell(VampiricGoblet.new(), 1)
	#self.add_new_spell(BoreasSwiftness.new(), 1)
	#self.add_new_spell(TitansSkin.new(), 1)
	#self.add_new_spell(YggdrasilTea.new(), 1)
	#self.add_new_spell(SoulPiercer.new(), 1)
	#self.add_new_spell(WrathWand.new(), 1)
	

func hurt_myself():
	for mob: MobBehaviourModule in mobs_on_damage_range:
		self.take_damage(mob)
	
	if (mobs_on_damage_range.size() == 0):
		self.player_sprite.material.set_shader_parameter("hit_flash_enabled", false)

func take_damage(mob_behaviour: MobBehaviourModule = null, bullet_module: BulletModule = null):
	self.player_sprite.material.set_shader_parameter("hit_flash_enabled", true)

	var current_health = health_module.get_health()

	var damage_received = mob_behaviour.damage if mob_behaviour != null else bullet_module.damage

	var damage_to_take = damage_received * (100/(100 + self.stats_module.current_defense))

	self.health_module.set_health(current_health - damage_to_take)

func _physics_process(delta: float) -> void:
	cast_cooldown = max(cast_cooldown - delta, 0)
	lazy_cast_cooldown = max(lazy_cast_cooldown - delta, 0)

	if Input.is_action_just_pressed("shoot") and cast_cooldown <= 0:
		shoot()
		
	if Input.is_action_pressed("shoot") and lazy_cast_cooldown <= 0:
		shoot()

func shoot():
	var bullet_instance = self.bullet.instantiate()
	var bullet_module = bullet_instance.bullet_module
	bullet_instance.global_position = wand_tip.position

	var spell_context = SpellContext.new()

	spell_context.bullet_module = bullet_module

	#for spell in spells:
		#if spell.get_event_spell_type() == EventSpell.EventSpellType.PROJECTILE:
			#spell.apply_spell(spell_context)

	#NodeShake.apply_shake(player_sprite, 5, 20)
	
	magic_light.position = wand_tip.position 
	magic_light.texture_scale = randf_range(2, 2.8)
	magic_light.energy = randf_range(16, 18)
	magic_light.enabled = true

	var light_tween = get_tree().create_tween()
	light_tween.tween_property(magic_light, "energy", 0, 0.2)
	light_tween.parallel().tween_property(magic_light, "texture_scale", 0.8, 0.2)
	get_parent().add_child(bullet_instance)
	cast_cooldown = 0.5
	lazy_cast_cooldown = 2
	
	
	
	# Collision
func _on_body_entered(body: Node2D) -> void:
	var is_mob = Interface.node_implements_interface(body, Interface.Mob)
	if is_mob:
		var behaviour: MobBehaviourModule = body.behaviour_module
		mobs_on_damage_range.append(behaviour)

func _on_body_exited(body: Node2D):
	var is_mob = Interface.node_implements_interface(body, Interface.Mob)
	if is_mob:
		var behaviour: MobBehaviourModule = body.behaviour_module
		mobs_on_damage_range.erase(behaviour)

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
	stream_player.pitch_scale = randf_range(0.15, 0.2)
	stream_player.volume_db = 0

	get_parent().add_child(stream_player)

	var tween = get_tree().create_tween()
	hurt_box.set_deferred("disabled", true)
	tween.tween_callback(stream_player.play)
	tween.tween_property(
		player_sprite.material,
		"shader_parameter/dissolve_value",
		0.0,
		3.5
	).from(1.0)
	#tween.parallel().tween_property(player_sprite, "scale", Vector2(1, 0.06), 1)

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

func add_new_spell(spell: EventSpell, spell_level: int):
	self.spells.erase(spell)
	spell.current_level = spell_level

	match spell.get_event_spell_type():
		EventSpell.EventSpellType.PROJECTILE:
			pass
		EventSpell.EventSpellType.ENEMY_ACTION:
			var spell_context = SpellContext.new()
			spell_context.player = self

			spell.apply_spell(spell_context)
		EventSpell.EventSpellType.STATS_SPELL:
			var spell_context = SpellContext.new()
			spell_context.stats_module = self.stats_module
			spell_context.health_module = self.health_module
			spell_context.player = self

			spell.apply_spell(spell_context)
		EventSpell.EventSpellType.NODE_SPELL:
			var spell_context = SpellContext.new()
			spell_context.player = self

			spell.apply_spell(spell_context)
		EventSpell.EventSpellType.TIMER_SPELL:
			var spell_context = SpellContext.new()
			spell_context.player = self

			spell.apply_spell(spell_context)

	self.spells.append(spell)
