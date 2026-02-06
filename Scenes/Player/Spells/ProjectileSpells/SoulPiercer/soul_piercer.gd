class_name SoulPiercer extends EventSpell.ProjectileSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var sprite_texture = preload("res://Sprites/Spell Sprites/SoulPiercer.png")

@export var pierce_count = 0
var remaining_pierces
var current_level = 0
var max_level = 4
var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.PROJECTILE

func apply_spell(spell_context: SpellContext):
	self.validate(spell_context)
	## Scales with level
	self.pierce_count = self.current_level + 1 if self.current_level < 4 else int(INF)
	self.remaining_pierces = self.pierce_count
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
	## Interpolate correctly the level dependant skills in the description.
	## Also add a special color on the variable skill to make it easier for the player to see
	return "[b]Allows projectiles to pierce through up to [color=20877b]%s enemies.[/color][/b]

	'Magic sharpens the will into a perfect line.
No soul stands untouched in its path.'" % (
	## The code here is different from the calc to get pierce_count because this here is called before the
	## lvl up, and the apply_spell is called every bullet shot
	str(self.get_event_spell_next_level() + 1) if self.current_level < 3 else "an infinite amount of"
)

func get_event_spell_sprite_texture() -> Texture:
	return self.sprite_texture

func get_event_spell_current_level() -> int:
	return self.current_level

func get_event_spell_next_level() -> int:
	return self.current_level + 1

func get_event_spell_max_level() -> int:
	return self.max_level
	
func get_event_spell_max_level_detail() -> String:
	return "[color=6b0e1d]Infinite[/color] enemy piercing."
