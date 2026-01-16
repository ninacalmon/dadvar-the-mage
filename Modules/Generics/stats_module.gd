extends Resource
class_name StatsModule
signal level_up(level: int)

enum BuffableStats {
	MOVE_SPEED
}

@export var base_move_speed: float
var current_move_speed: float

const BASE_XP: float = 100.0
var experience: float = 0
var level: int = 1

var stat_buffs: Array[StatBuff]

func _setup_local_to_scene() -> void:
	## Initialize the current values with the base values
	## it is needed to do in here because the _init runs before the
	## @export variables are assigned, so we need to call this within setup_local_to_scene
	self.current_move_speed = self.base_move_speed


func recalculate_stats():	
	var stat_multipliers: Dictionary = {}
	var stat_addends: Dictionary = {}
	
	for buff in self.stat_buffs:
		var stat_name: String = (BuffableStats.keys()[buff.stat]).to_lower()
		
		match buff.buff_type:
			StatBuff.BuffType.MULTIPLY:
				if not stat_multipliers.has(stat_name):
					stat_multipliers[stat_name] = 0.0
				stat_multipliers[stat_name] += buff.buff_amount

				## Avoid negative multipliers to be added
				if stat_multipliers[stat_name] <= 0.0:
					stat_multipliers[stat_name] = 1.0
			StatBuff.BuffType.ADD:
				if not stat_addends.has(stat_name):
					stat_addends[stat_name] = 0.0
				stat_addends[stat_name] += buff.buff_amount
	
	for stat_name in stat_multipliers:
		var current_property_name: String = String("current_" + stat_name)
		var current_property_value = self.get(current_property_name) 

		var buffed_value = current_property_value * stat_multipliers[stat_name]

		self.set(current_property_name, buffed_value)
	
	for stat_name in stat_addends:
		var current_property_name: String = String("current_" + stat_name)
		var current_property_value = self.get(current_property_name) 

		var buffed_value = current_property_value + stat_addends[stat_name]

		self.set(current_property_name, buffed_value)

func set_experience(experience_to_add: float):
	var old_level: int = level
	self.experience += experience_to_add
	
	if not old_level == self.get_level():
		self.level_up.emit(self.get_level())
		## Not needed as we will not upgrade our stats on level up (only with buffs)
		# recalculate_stats()
	
func get_level():
	return floor(max(1.0, sqrt(self.experience / BASE_XP) + 0.5))
	
func add_buff(buff: StatBuff) -> void:
	self.stat_buffs.append(buff)
	self.recalculate_stats.call_deferred()
	
func remove_buff(buff: StatBuff) -> void:
	self.stat_buffs.erase(buff)
	self.recalculate_stats.call_deferred()
