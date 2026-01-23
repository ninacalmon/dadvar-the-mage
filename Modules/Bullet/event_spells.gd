@abstract
class_name EventSpell
extends Resource

var placeholder_texture = preload("res://Sprites/Spell Sprites/Placeholder.png")

enum EventSpellType {
	INVALID,
	PROJECTILE,
	ENEMY_ACTION,
	STATS_SPELL,
	NODE_SPELL
}

func get_event_spell_type() -> EventSpellType:
	push_error("get_my_property() must be implemented")
	return EventSpellType.INVALID

func get_event_spell_description() -> String:
	push_error("get_event_spell_description() must be implemented")
	return ""

func get_event_spell_title() -> String:
	return prettify_class_name(self.get_script().get_global_name())

func get_event_spell_sprite_texture() -> Texture:
	return placeholder_texture

func prettify_class_name(name: String) -> String:
	var regex = RegEx.new()
	regex.compile("([a-z])([A-Z])")
	return regex.sub(name, "$1 $2", true)

## Each class that inherits this will need to implement apply hability,
## which is unique for each class.
@abstract func apply_spell(spell_context: SpellContext)

@abstract
class ProjectileSpell extends EventSpell:
	signal destroy

	var event_spell_type: EventSpellType = EventSpellType.PROJECTILE

	func get_event_spell_type() -> EventSpellType:
		return EventSpellType.PROJECTILE

	var already_emitted = false
	func validate(spell_context: SpellContext):
			assert(spell_context.bullet_module != null, "Projectile spell %s needs bullet module to apply effect" % self.get_script().get_global_name())

@abstract
class EnemyActionSpell extends EventSpell:
	var event_spell_type: EventSpellType = EventSpellType.ENEMY_ACTION

	func get_event_spell_type() -> EventSpellType:
		return EventSpellType.ENEMY_ACTION

	func validate(spell_context: SpellContext):
			assert(spell_context.player != null, "Enemy action spell %s needs player node to apply effect" % self.get_script().get_global_name())
			assert(
				spell_context.player is Player,
				"Player provided to EnemyActionSpell %s is invalid" % self.get_script().get_global_name()
			)

@abstract
class StatsSpell extends EventSpell:
	var event_spell_type: EventSpellType = EventSpellType.STATS_SPELL
	var stat_modifier: StatModifier

	func get_event_spell_type() -> EventSpellType:
		return EventSpellType.STATS_SPELL

	func validate(spell_context: SpellContext):
		assert(
			spell_context.stats_module != null
			and spell_context.health_module != null, "StatsSpell %s needs Stats Module OR Health Module to apply effect" % self.get_script().get_global_name())
		assert(
			spell_context.stats_module is StatsModule
			or spell_context.health_module is HealthModule,
			"Stats Module OR Health Module provided to StatsSpell %s is invalid" % self.get_script().get_global_name()
		)
		assert(stat_modifier != null, "StatsSpell %s needs a stat modifier defined to apply effect" % self.get_script().get_global_name())

@abstract
class NodeSpell extends EventSpell:
	var event_spell_type: EventSpellType = EventSpellType.NODE_SPELL
	var scene: PackedScene

	func get_event_spell_type() -> EventSpellType:
		return EventSpellType.NODE_SPELL

	func validate(spell_context: SpellContext):
		assert(spell_context.player != null, "Node spell %s needs player node to apply effect" % self.get_script().get_global_name())
		assert(
			spell_context.player is Player,
			"Player provided to NodeSpell %s is invalid" % self.get_script().get_global_name()
		)
		assert(scene != null, "NodeSpell %s needs a scene defined to apply effect" % self.get_script().get_global_name())
