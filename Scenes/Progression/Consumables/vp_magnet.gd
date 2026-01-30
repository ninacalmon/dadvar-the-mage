extends Area2D

#var range_circle: CollisionShape2D

#var original_range_scale: Vector2 = Vector2(1, 1)
var temporary_range_scale: Vector2 = Vector2(50, 50)

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("PlayerGroup"):
		$CollisionShape2D.set_deferred("disabled", true)
		self.hide()
		var stream_player = $collect_sound
		stream_player.play()
		stream_player.reparent(get_tree().get_first_node_in_group("Main"))
		stream_player.finished.connect(func ():
			stream_player.queue_free()
		)
		var vp_collector = area.get_node("VpCollector")
		var vp_range_static = vp_collector.get_node("VpRange")

		var range_circle = vp_collector.get_node("VpRangeModifiable")
		var original_range_scale = vp_range_static.scale

		start_magnet(range_circle, original_range_scale)

func start_magnet(range_circle: CollisionShape2D, original_range_scale: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(range_circle, "scale", temporary_range_scale, 2)
	tween.tween_property(range_circle, "scale", original_range_scale, 1)
	tween.tween_callback(self.queue_free)
