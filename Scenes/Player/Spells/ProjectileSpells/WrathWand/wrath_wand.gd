class_name WrathWand extends EventSpell.ProjectileSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var sprite_texture = preload("res://Sprites/Spell Sprites/WrathWand.png")

@export var damage_to_add = 0

var current_level = 0
var max_level = 4
var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.PROJECTILE

func apply_spell(spell_context: SpellContext):
	self.validate(spell_context)
	## Scales with level
	self.damage_to_add = 5 * current_level 
	
	var bullet_module = spell_context.bullet_module

	bullet_module.damage += self.damage_to_add

func get_event_spell_description() -> String:
	return "[b]Spells cast through the wand deal increased damage.[/b]

	'The wand amplifies destructive intent.
Spells land with greater weight.'"

func get_event_spell_sprite_texture() -> Texture:
	return self.sprite_texture

func get_event_spell_current_level() -> int:
	return self.current_level

func get_event_spell_next_level() -> int:
	return self.current_level + 1

func get_event_spell_max_level() -> int:
	return self.max_level
	
func get_event_spell_max_level_detail() -> String:
	return "Damage [color=6b0e1d]fully[/color] maximized."
