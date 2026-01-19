@abstract
class_name EventSpell
extends Resource

enum EventSpellType {
	PROJECTILE,
	ACTIVATION,
	ENEMY_ACTION
}

## Each class that inherits this will need to implement apply hability,
## which is unique for each class.
@abstract func apply_spell(spell_context: SpellContext)

@abstract
class ProjectileSpell extends EventSpell:
	signal destroy
	
	var event_spell_type = EventSpellType.PROJECTILE
	var already_emitted = false
	func validate(spell_context: SpellContext):
			assert(spell_context.bullet_module != null, "Projectile spell needs bullet module to apply effect")

@abstract
class EnemyActionSpell extends EventSpell:
	var event_spell_type = EventSpellType.ENEMY_ACTION

	func validate(spell_context: SpellContext):
			assert(spell_context.player != null, "Enemy action spell needs player node to apply effect")
			assert(
				spell_context.player is Player,
				"Player provided to EnemyActionSpell is invalid"
			)
