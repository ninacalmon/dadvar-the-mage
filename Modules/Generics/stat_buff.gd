extends Resource
class_name StatBuff

enum BuffType {
	ADD,
	MULTIPLY
}

@export var stat: StatsModule.BuffableStats
@export var buff_amount: float
@export var buff_type: BuffType

# Constructor to create new stat buffs
func _init(
	_stat: StatsModule.BuffableStats, 
	_buff_amount: float, 
	_buff_type: StatBuff.BuffType
	):
		stat = _stat
		buff_amount = _buff_amount
		buff_type = _buff_type
