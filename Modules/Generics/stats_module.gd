extends Resource
class_name StatsModule
signal level_up(level: int)

enum ModifiableStats {
	MOVE_SPEED
}

@export var base_move_speed: float
var current_move_speed: float

const BASE_XP: float = 100.0
var experience: float = 0
var level: int = 1

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

func add_experience(experience_to_add: float):
	var old_level: int = level
	self.experience += experience_to_add
	var new_level: int = self.get_level()

	if not old_level == new_level:
		self.level = new_level
		self.level_up.emit(self.get_level())
		## Not needed as we will not upgrade our stats on level up (only with buffs)
		# recalculate_stats()
	
func get_level():
	return floor(max(1.0, sqrt(self.experience / BASE_XP) + 0.5))
	
func add_modifier(modifier: StatModifier) -> void:
	self.stat_modifiers.append(modifier)
	self.recalculate_stats.call_deferred()
	
func remove_modifier(modifier: StatModifier) -> void:
	self.stat_modifiers.erase(modifier)
	self.recalculate_stats.call_deferred()
