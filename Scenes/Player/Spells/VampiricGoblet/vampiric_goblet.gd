class_name VampiricGoblet extends EventSpell.EnemyActionSpell
## This abstract class implements the interface in order to have a verification on itself
var implements = Interface.BulletHabilities

var hability_type: EventSpell.EventSpellType = EventSpell.EventSpellType.ENEMY_ACTION

@export var percentage_health_steal: float = 1
var player: Player

func apply_spell(spell_context: SpellContext):
	self.validate(spell_context)

	player = spell_context.player

	EventBus.enemy_died.connect(steal_health)
	
func steal_health(mob_behaviour: MobBehaviourModule):
	var enemy_health = mob_behaviour.health_module
	var player_current_health = player.health_module.get_health()
	var health_to_add = (percentage_health_steal/100) * enemy_health.get_max_health()

	player.health_module.set_health(player_current_health + health_to_add)
