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
