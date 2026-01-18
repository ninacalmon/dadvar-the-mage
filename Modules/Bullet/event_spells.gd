@abstract
class_name EventSpell
extends Resource

enum EventSpellType {
	PROJECTILE,
	ACTIVATION
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
