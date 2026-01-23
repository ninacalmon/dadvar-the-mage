class_name OgresScent extends EventSpell.NodeSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var sprite_texture = preload("uid://u0nob4ja1i7q")

var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.NODE_SPELL

@export var damage: float = 5
@export var tick: float = 2
var player: Player

func apply_spell(spell_context: SpellContext):
	self.player = spell_context.player
	## Here add the scent scene
	self.scene = preload("uid://butv0gsjj8yp1")

	self.validate(spell_context)
	self.exhale_scent(self.scene)
	
func exhale_scent(scent_scene: PackedScene):
	var scent_instance: OgresScentArea = scent_scene.instantiate()

	scent_instance.setup_scent_area(self.damage, self.tick, 160)

	self.player.add_child(scent_instance)

func get_event_spell_description() -> String:
	return "[b]Emits a putrid scent that continuously damages enemies who draw near.[/b]
	
	'The air grows heavy around the bearer.
Few can endure its presence.'"

func get_event_spell_sprite_texture() -> Texture:
	return sprite_texture
