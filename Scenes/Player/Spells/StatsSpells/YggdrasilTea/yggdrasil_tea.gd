class_name YggdrasilTea extends EventSpell.StatsSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var sprite_texture = preload("res://Sprites/Spell Sprites/YggdrasilTea.png")

var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.STATS_SPELL

func apply_spell(spell_context: SpellContext):
	self.stat_modifier = StatModifier.CreateStatModifier(
		StatsModule.ModifiableStats.MAX_HEALTH,
		30,
		StatModifier.ModifierType.ADD
	)
	self.validate(spell_context)

	var health_module = spell_context.health_module
	var player = spell_context.player
	var old_max_health = health_module.get_max_health()
	var new_max_health = health_module.get_max_health() + self.stat_modifier.modifier_amount
	health_module.set_max_health(new_max_health)

	var health_diff = new_max_health - old_max_health

	health_module.set_health(health_module.get_health() + health_diff)
	NumberPopUp.create_health_number_pop_up(health_diff, player, true)

func get_event_spell_description() -> String:
	return "[b]Infuses your essence with the vitality of the World Tree, increasing max health[/b]
	
	'Life flows from the World Tree itself.
Its roots strengthen both body and spirit.'"

func get_event_spell_sprite_texture() -> Texture:
	return sprite_texture
