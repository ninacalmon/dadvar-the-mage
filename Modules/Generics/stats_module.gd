extends Resource
class_name StatsModule

enum ModifiableStats {
	MOVE_SPEED
}

@export var base_move_speed: float
var current_move_speed: float

#const BASE_VP: float = 100.0
const PROGRESS_DIFFICULTY = 1.6
var void_power: float = 0
var current_level: int = 1
var vp_needed: float = 150

var stat_modifiers: Array[StatModifier]

func _setup_local_to_scene() -> void:
	## Initialize the current values with the base values
	## it is needed to do in here because the _init runs before the
	## @export variables are assigned, so we need to call this within setup_local_to_scene
	self.current_move_speed = self.base_move_speed


func recalculate_stats():
	var stat_multipliers: Dictionary = {}
	var stat_addends: Dictionary = {}

	for modifier in self.stat_modifiers:
		var stat_name: String = (ModifiableStats.keys()[modifier.stat]).to_lower()

		match modifier.modifier_type:
			StatModifier.ModifierType.MULTIPLY:
				if not stat_multipliers.has(stat_name):
					stat_multipliers[stat_name] = 1.0
				stat_multipliers[stat_name] += modifier.modifier_amount

				## Avoid negative multipliers to be added
				#if stat_multipliers[stat_name] <= 0.0:
					#stat_multipliers[stat_name] = 1.0
			StatModifier.ModifierType.ADD:
				if not stat_addends.has(stat_name):
					stat_addends[stat_name] = 0.0
				stat_addends[stat_name] += modifier.modifier_amount

	for stat_name in stat_multipliers:
		var current_property_name: String = String("current_" + stat_name)
		var current_property_value = self.get(current_property_name) 

		var modify_applied_value = current_property_value * stat_multipliers[stat_name]

		self.set(current_property_name, modify_applied_value)
	
	for stat_name in stat_addends:
		var current_property_name: String = String("current_" + stat_name)
		var current_property_value = self.get(current_property_name) 

		var modify_applied_value = current_property_value + stat_addends[stat_name]

		self.set(current_property_name, modify_applied_value)

func add_void_power(void_power_to_add: float):
	#var old_level: int = current_level
	self.void_power += void_power_to_add
	print(void_power)
	if self.void_power >= vp_needed:
		self.current_level += 1
		print("LEVEL UPPPPPPPPPPPPPPPPP")
		## SEND LEVEL DIFFERENCE AS WELL IN ORDER TO AVOID PLAYER LEVELING UP
		## TWICE AND GETTIN ONLY ONE SPELL AS REWARD
		vp_needed = self.get_vp_needed_to_next_level()
		EventBus.player_level_up.emit(self.current_level)
	EventBus.vp_changed.emit(self.void_power)
		## Not needed as we will not upgrade our stats on level up (only with buffs)
		# recalculate_stats()
	
#func get_level():
	##return floor(max(1.0, (pow(self.void_power / BASE_VP, 1/1.1) + 0.5) + 1)) 
	#return pow(self.get_vp_needed_to_next_level() / 150, )

func get_vp_needed_to_next_level() -> float:
	#return pow(self.BASE_VP*(self.get_level() - 0.5), 1.1)
	return 150 * pow(self.current_level, PROGRESS_DIFFICULTY)
	
func add_modifier(modifier: StatModifier) -> void:
	self.stat_modifiers.append(modifier)
	self.recalculate_stats.call_deferred()
	
func remove_modifier(modifier: StatModifier) -> void:
	self.stat_modifiers.erase(modifier)
	self.recalculate_stats.call_deferred()
