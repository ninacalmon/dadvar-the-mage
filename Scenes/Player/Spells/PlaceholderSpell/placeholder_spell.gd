class_name SpellWaste extends EventSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var sprite_texture = preload("res://Sprites/Spell Sprites/Placeholder.png")

@export var pierce_count = 3
var remaining_pierces

var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.PROJECTILE

func apply_spell(_spell_context: SpellContext):
	print("Placeholder spell!")

func get_event_spell_description() -> String:
	return "[b]Powerless spell[/b]
	
	'Once powerful, now incomplete.
	Its magic faded long ago.
	No effect remains.'"

func get_event_spell_sprite_texture() -> Texture:
	return sprite_texture
