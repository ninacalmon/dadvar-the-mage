class_name BoreasSwiftness extends EventSpell.StatsSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var sprite_texture = preload("res://Sprites/Spell Sprites/BoreasSwiftness2.png")

var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.STATS_SPELL
var current_level = 0
var max_level = 3
var switfness_to_reduce = 0.93

func apply_spell(spell_context: SpellContext):
	self.stat_modifier = StatModifier.CreateStatModifier(
		StatsModule.ModifiableStats.CAST_COOLDOWN,
		switfness_to_reduce,
		StatModifier.ModifierType.MULTIPLY
	)
	self.validate(spell_context)

	var stats_module = spell_context.stats_module
	stats_module.add_modifier(self.stat_modifier)

func get_event_spell_description() -> String:
	return "[b]Each projectile carries Boreas’ breath, shortening your cast cooldown by [color=20877b]%.0f%%.[/color][/b]
	
	'Boreas whispers through your hands.
Speed follows every motion.'" % ((1 - self.switfness_to_reduce) * 100)

func get_event_spell_sprite_texture() -> Texture:
	return sprite_texture

func get_event_spell_title() -> String:
	return "Borea's Swiftness"

func get_event_spell_current_level() -> int:
	return self.current_level

func get_event_spell_next_level() -> int:
	return self.current_level + 1

func get_event_spell_max_level() -> int:
	return self.max_level

func get_event_spell_max_level_detail() -> String:
	return "[color=6b0e1d]No cooldown[/color] beetween shots."
