class_name ProfaneBolt extends EventSpell.TimerSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var sprite_texture = preload("res://Sprites/Spell Sprites/ProfaneBolt.png")

var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.TIMER_SPELL

## Here add the bolt texture
@export var bolt_vfx: PackedScene = preload("res://Scenes/Player/Spells/TimerSpells/ProfaneBolt/bolt.tscn")
@export var damage: float = 20
@export var tick: float = 2
var light_bolt_screen_time = 0.1

var player: Player

func apply_spell(spell_context: SpellContext):
	self.player = spell_context.player
	self.validate(spell_context)

	var main_scene_node = self.player.get_tree().get_first_node_in_group(Global.GROUPS_DIC[Global.Groups.MAIN])

	var lightning_timer = Timer.new()
	lightning_timer.wait_time = self.tick
	lightning_timer.autostart = true
	lightning_timer.one_shot = false

	lightning_timer.timeout.connect(emit_lightning.bind(main_scene_node, self.bolt_vfx))

	player.add_child(lightning_timer)

func emit_lightning(main_scene_node: Node, bolt_scene: PackedScene):
	var nearest_enemy: Node = self.get_nearest_enemy_to_player(main_scene_node)

	if nearest_enemy:
		var visual_effect = bolt_scene.instantiate()

		nearest_enemy.take_damage(damage)
		nearest_enemy.add_child(visual_effect)
		main_scene_node.get_tree().create_timer(light_bolt_screen_time).timeout.connect(visual_effect.queue_free)

## THIS HERE MAY TURN INTO A TIMER SPELL CLASS FUNCTION INSTEAD
func get_nearest_enemy_to_player(starting_node: Node) -> Node:
	var min_distance = INF
	var nearest_node = null

	var damageable_nodes: Array[Node] = Interface \
	.get_all_nodes_implements_interface_bfs(starting_node, Interface.Damageable)
	
	for node in damageable_nodes:
		var distance_to_caster = self.player.global_position.distance_squared_to(node.global_position)
		
		if distance_to_caster < min_distance:
			min_distance = distance_to_caster
			nearest_node = node

	return nearest_node

func get_event_spell_description() -> String:
	return "[b]Calls down corrupted lightning to strike the nearest enemy.[/b]
	
	'The sky answers with forbidden power.
Judgment finds its closest mark.'"

func get_event_spell_sprite_texture() -> Texture:
	return sprite_texture
