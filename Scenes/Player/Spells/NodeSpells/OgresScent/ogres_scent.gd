class_name OgresScent extends EventSpell.NodeSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var sprite_texture = preload("res://Sprites/Spell Sprites/ogresScent.png")

var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.NODE_SPELL

var current_level = 0
var max_level = 5

@export var damage: float = 10
@export var base_tick: float = 1.8
var current_tick = base_tick

@export var base_area_scale: Vector2 = Vector2(18, 18)
var current_area_scale = base_area_scale

func get_event_spell_description() -> String:
	return "[b]Emits a putrid scent that continuously damages enemies who draw near.[/b]
	
	'The air grows heavy around the bearer.
Few can endure its presence.'"

func get_event_spell_sprite_texture() -> Texture:
	return sprite_texture

func apply_spell(spell_context: SpellContext):
	## Here add the scent scene
	self.scene = preload("uid://butv0gsjj8yp1")

	self.current_tick = max(self.base_tick - self.current_level / 6.0, 0.4)
	self.current_area_scale = self.base_area_scale * min(ceil(current_level / 4.0), 1.5)

	self.validate(spell_context)
	self.exhale_scent(self.scene, spell_context.player)
	
func exhale_scent(scent_scene: PackedScene, spell_caster: Node):
	for child in spell_caster.get_children():
		if child is OgresScentArea:
			child.queue_free()
			break

	var scent_instance: OgresScentArea = scent_scene.instantiate()
	scent_instance.setup_scent_area(self.damage, self.current_tick, self.current_area_scale)
	spell_caster.add_child(scent_instance)

func get_event_spell_current_level() -> int:
	return current_level

func get_event_spell_next_level() -> int:
	return current_level + 1

func get_event_spell_max_level() -> int:
	return max_level
	
func get_event_spell_max_level_detail() -> String:
	return "Greatly increased [color=6b0e1d]range.[/color]"
