extends Area2D

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerGroup"):
		var player: Player = area
		$CollisionShape2D.set_deferred("disabled", true)
		self.hide()
		var stream_player = $collect_sound
		stream_player.play()
		stream_player.reparent(get_tree().get_first_node_in_group("Main"))
		stream_player.finished.connect(func ():
			stream_player.queue_free()
		)

		var current_health = player.health_module.get_health()
		var max_health = player.health_module.get_max_health()
		var health_to_add = max_health / 3

		NumberPopUp.create_health_number_pop_up(health_to_add, player, true)

		var target_health = min(current_health + health_to_add, max_health)
		player.health_module.set_health(target_health)
		queue_free()
