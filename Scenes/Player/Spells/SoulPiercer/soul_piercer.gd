class_name SoulPiercer extends EventSpell.ProjectileSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

@export var pierce_count = 3
var remaining_pierces

var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.PROJECTILE

func apply_spell(spell_context: SpellContext):
	self.validate(spell_context)
	self.remaining_pierces = pierce_count
	self.already_emitted = false
	
	var bullet_module = spell_context.bullet_module

	bullet_module.enemy_hit.connect(pierce_enemy)
	## destroy signal comes from parent ProjectileSpell
	self.destroy.connect(bullet_module.destroy)
	
func pierce_enemy(_enemy):
	self.remaining_pierces -= 1

	if (remaining_pierces <= 0 and !already_emitted):
		destroy.emit()
		## already_emitted comes from parent ProjectileSpell
		self.already_emitted = true
		
func get_event_spell_description() -> String:
	return "Allows the user to fire piercing projectiles. Pierces 3 enemies max."
