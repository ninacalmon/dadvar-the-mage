class_name BoreasSwiftness extends EventSpell.StatsSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var sprite_texture = preload("res://Sprites/Spell Sprites/Placeholder.png")

var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.STATS_SPELL

func apply_spell(spell_context: SpellContext):
	self.stat_modifier = StatModifier.CreateStatModifier(
		StatsModule.ModifiableStats.CAST_COOLDOWN,
		0.8,
		StatModifier.ModifierType.MULTIPLY
	)
	self.validate(spell_context)

	var stats_module = spell_context.stats_module

	stats_module.add_modifier(self.stat_modifier)

func get_event_spell_description() -> String:
	return "[b]Each projectile carries Boreas’ breath, shortening your cast cooldown.[/b]
	
	'Boreas whispers through your hands.
Speed follows every motion.'"

func get_event_spell_sprite_texture() -> Texture:
	return sprite_texture
