extends Resource
class_name StatModifier

enum ModifierType {
	ADD,
	MULTIPLY
}

@export var stat: StatsModule.ModifiableStats
@export var modifier_amount: float
@export var modifier_type: ModifierType

 #if we have a constructor, some weird things happen when you define
 #in the inspector.
# (Because Godot does not know what to pass in the constructor when instantiating,
# and the export variables are assigned only after _init, which is the constructor)
# To instantiate through code we will need an static factory function

static func CreateStatModifier(
	stat_to_modify: StatsModule.ModifiableStats,
	modify_amount: float,
	modify_type: ModifierType
	):
		var modifier := StatModifier.new()
		modifier.stat = stat_to_modify
		modifier.modifier_amount = modify_amount
		modifier.modifier_type = modify_type

		return modifier
