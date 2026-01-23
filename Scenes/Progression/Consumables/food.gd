extends Area2D

#@export var player: Area2D
#@onready var health: HealthModule = player.find_children("*", "HealthModule")[0]

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerGroup"):
		var player: Player = area
		$CollisionShape2D.set_deferred("disabled", true)
		self.hide()
		
		var current_health = player.health_module.get_health()
		var max_health = player.health_module.get_max_health()
		var health_to_add = max_health / 3

		var target_health = min(current_health + health_to_add, max_health)
		player.health_module.set_health(target_health)
		queue_free()
