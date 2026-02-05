class_name ProfaneBolt extends EventSpell.TimerSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var sprite_texture = preload("res://Sprites/Spell Sprites/ProfaneBolt.png")

var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.TIMER_SPELL

## Here add the bolt texture
@export var bolt_vfx: PackedScene = preload("res://Scenes/Player/Spells/TimerSpells/ProfaneBolt/bolt.tscn")
@export var damage: float = 50
@export var bolts_to_trigger = 1

@export var base_tick: float = 2
var current_tick = base_tick

var light_bolt_screen_time = 0.1

var current_level = 0
var max_level = 5

func apply_spell(spell_context: SpellContext):
	self.validate(spell_context)

	var main_scene_node = spell_context.player.get_tree().get_first_node_in_group('Main')
	## MAYBE SET THE TICK TO ONE SECOND WHEN IT REACHES THE MAX LEVEL
	self.current_tick = max(self.base_tick - self.current_level / 6.0, 0.5)

	if self.current_level == self.get_event_spell_max_level():
		self.bolts_to_trigger = 2

	var existing_timer: Timer = spell_context.player.get_node_or_null("LightningTimer")

	if existing_timer:
		existing_timer.wait_time = self.current_tick
		return
	
	var lightning_timer = Timer.new()
	lightning_timer.wait_time = self.current_tick
	lightning_timer.autostart = true
	lightning_timer.one_shot = false
	lightning_timer.name = "LightningTimer"

	lightning_timer.timeout.connect(emit_lightning.bind(main_scene_node, self.bolt_vfx, spell_context.player))
	spell_context.player.add_child(lightning_timer)

func emit_lightning(main_scene_node: Node, bolt_scene: PackedScene, caster: Node):
	var enemies_already_hit: Array[Node] = []

	for i in range(bolts_to_trigger):
		var nearest_enemy: Node = self.get_nearest_enemy_to_caster(main_scene_node, caster, enemies_already_hit)
	
		if nearest_enemy:
			var visual_effect = bolt_scene.instantiate()
			nearest_enemy.take_damage(damage)
			
			visual_effect.global_position = nearest_enemy.global_position
			main_scene_node.add_child(visual_effect)

			main_scene_node.get_tree().create_timer(light_bolt_screen_time).timeout.connect(visual_effect.queue_free)
			enemies_already_hit.append(nearest_enemy)

## THIS HERE MAY TURN INTO A TIMER SPELL CLASS FUNCTION INSTEAD
func get_nearest_enemy_to_caster(starting_node: Node, caster: Node, already_hit: Array[Node]) -> Node:
	var min_distance = INF
	var nearest_node = null

	var damageable_nodes: Array[Node] = Interface \
	.get_all_nodes_implements_interface_bfs(starting_node, Interface.Damageable)
	
	for node in damageable_nodes:
		if node in already_hit:
			continue

		var distance_to_caster = caster.global_position.distance_squared_to(node.global_position)
		
		if distance_to_caster < min_distance:
			min_distance = distance_to_caster
			nearest_node = node

	return nearest_node

func get_event_spell_description() -> String:
	return "[b]Calls down corrupted lightning to strike the nearest enemy each [color=20877b]%.1f seconds.[/color][/b]
	
	'The sky answers with forbidden power.
Judgment finds its closest mark.'" % (self.base_tick - self.get_event_spell_next_level() / 6.0)

func get_event_spell_sprite_texture() -> Texture:
	return sprite_texture

func get_event_spell_current_level() -> int:
	return current_level

func get_event_spell_next_level() -> int:
	return current_level + 1

func get_event_spell_max_level() -> int:
	return max_level
