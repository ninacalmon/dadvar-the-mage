extends ProgressBar
#
@export var character: Area2D

@onready var health: HealthModule = character.find_children("*", "HealthModule")[0]

func _ready() -> void:
	max_value = health.get_max_health()
	value = health.get_health()
	# This here connects to the health_changed signal emitted by the health module.
	# This is the equivalent of using the interface, but the function connected does not
	# show the green arrow on the side
	health.health_changed.connect(_update_bar)

func _update_bar(_diff: float) -> void:
	value = health.get_health()
