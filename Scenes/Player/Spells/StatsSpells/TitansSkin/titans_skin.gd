class_name TitansSkin extends EventSpell.StatsSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var sprite_texture = preload("res://Sprites/Spell Sprites/TitansSkin.png")
var current_level = 0
var max_level = 3
var defense_to_add = 18
var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.STATS_SPELL

func apply_spell(spell_context: SpellContext):
	self.stat_modifier = StatModifier.CreateStatModifier(
		StatsModule.ModifiableStats.DEFENSE,
		self.defense_to_add * self.current_level,
		StatModifier.ModifierType.ADD
	)

	self.validate(spell_context)

	var stats_module = spell_context.stats_module
	stats_module.add_modifier(self.stat_modifier)

func get_event_spell_description() -> String:
	return "[b]Makes your skin harder, taking less damage[/b]
	
	'Stone-bound magic coats the flesh.
The wearer endures beyond mortal limits.'"

func get_event_spell_sprite_texture() -> Texture:
	return sprite_texture

func get_event_spell_title() -> String:
	return "Titan's skin"

func get_event_spell_current_level() -> int:
	return self.current_level

func get_event_spell_next_level() -> int:
	return self.current_level + 1

func get_event_spell_max_level() -> int:
	return self.max_level
