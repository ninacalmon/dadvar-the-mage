class_name VampiricGoblet extends EventSpell.EnemyActionSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var sprite_texture = preload("res://Sprites/Spell Sprites/VampiricGoblet.png")
var current_level = 0
var max_level = 1

var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.ENEMY_ACTION

@export var percentage_health_steal: float = 1

func apply_spell(spell_context: SpellContext):
	self.validate(spell_context)

	## In this case, bound arguments are always passed after the signal arguments passed
	## by the emitter. Therefore, mob_behaviour, which comes from the emitter, comes first
	## and then the arguments I have bound in order
	EventBus.enemy_died.connect(steal_health.bind(spell_context.player))
	
func steal_health(mob_behaviour: MobBehaviourModule, caster: Node):
	var enemy_health = mob_behaviour.health_module
	var player_current_health = caster.health_module.get_health()
	var health_to_add = (percentage_health_steal/100) * enemy_health.get_max_health()

	NumberPopUp.create_health_number_pop_up(health_to_add, caster, true)
	caster.health_module.set_health(player_current_health + health_to_add)

func get_event_spell_description() -> String:
	return "[b]Allows the user to draw blood from enemies upon their death.[/b]
	
	'The chalice resonates with fading vitality.
What remains seeks a new bearer.'"

func get_event_spell_sprite_texture() -> Texture:
	return self.sprite_texture

func get_event_spell_current_level() -> int:
	return self.current_level

func get_event_spell_next_level() -> int:
	return self.current_level + 1

func get_event_spell_max_level() -> int:
	return self.max_level
