@abstract
class_name EventSpell
extends Resource

enum EventSpellType {
	INVALID,
	PROJECTILE,
	ACTIVATION,
	ENEMY_ACTION
}

func get_event_spell_type() -> EventSpellType:
	push_error("get_my_property() must be implemented")
	return EventSpellType.INVALID

func get_event_spell_description() -> String:
	push_error("get_event_spell_description() must be implemented")
	return ""

func get_event_spell_title() -> String:
	return self.get_script().get_global_name()

## Each class that inherits this will need to implement apply hability,
## which is unique for each class.
@abstract func apply_spell(spell_context: SpellContext)

@abstract
class ProjectileSpell extends EventSpell:
	signal destroy

	var event_spell_type = EventSpellType.PROJECTILE

	func get_event_spell_type() -> EventSpellType:
		return EventSpellType.PROJECTILE

	var already_emitted = false
	func validate(spell_context: SpellContext):
			assert(spell_context.bullet_module != null, "Projectile spell needs bullet module to apply effect")

@abstract
class EnemyActionSpell extends EventSpell:
	var event_spell_type = EventSpellType.ENEMY_ACTION

	func get_event_spell_type() -> EventSpellType:
		return EventSpellType.ENEMY_ACTION

	func validate(spell_context: SpellContext):
			assert(spell_context.player != null, "Enemy action spell needs player node to apply effect")
			assert(
				spell_context.player is Player,
				"Player provided to EnemyActionSpell is invalid"
			)
