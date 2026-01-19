class_name HealthModule
extends Node

signal health_changed(diff: float)
signal max_health_changed(diff: float)
signal health_depleted

@export var max_health: float
@export var immortality: bool = false

var immortality_timer: Timer = null

@onready var health: float = max_health

func _ready():
	if immortality:
		print("IMMORTALITY ON")

func set_max_health(health_value: float) -> void:
	if not health_value == max_health:
		var health_difference = health_value - max_health
		max_health = health_value
		max_health_changed.emit(health_difference)
		
		if health > max_health:
			health = max_health

func get_max_health() -> float:
	return max_health

func set_health(health_value: float):
	if health_value < health and immortality:
		return
	
	if not health_value == health:
		## If health value passed in is greater than max health,
		## then the player/mob has healed more than the max_health, therefore we just set
		## its current health as max_health
		var health_value_capped = min(health_value, max_health)
		var difference = health_value_capped - health
		health = health_value_capped
		health_changed.emit(difference)

		if health <= 0:
			health_depleted.emit()

func get_health() -> float:
	return health

func set_immortality(value: bool) -> void:
	immortality = value

func get_immortality() -> bool:
	return immortality
