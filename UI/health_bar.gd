extends TextureProgressBar
#
@export var character: Area2D

@onready var health: HealthModule = character.find_children("*", "HealthModule")[0]

func _ready() -> void:
	self.max_value = self.health.get_max_health()
	self.value = self.health.get_health()
	# This here connects to the health_changed signal emitted by the health module.
	# This is the equivalent of using the interface, but the function connected does not
	# show the green arrow on the side
	self.health.health_changed.connect(_update_bar)
	self.health.max_health_changed.connect(_update_max_bar_value)

func _update_bar(_diff: float) -> void:
	value = health.get_health()

func _update_max_bar_value(_diff: float) -> void:
	self.max_value = self.health.get_max_health()
	self.value = self.health.get_health()
