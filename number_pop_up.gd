extends Node

const NUMBERS_POP_UP: PackedScene = preload("uid://nftw0v06esfn")

func create_number_pop_up(value: float, position: Vector2, show_time: float = 2, parent: Node2D = null):
	if value > 0:
		pass
	#var player: Player = get_tree().get_first_node_in_group("PlayerGroup")
	var number_pop_up: RichTextLabel = NUMBERS_POP_UP.instantiate()
	var gradient: Gradient = number_pop_up.get_meta("Gradient")
	
	## add base damage (10) multiplier in player.stats_module. vvv
	var value_normalized: float = (value - 10.0) / (100.0 - 10.0)
	
	var color: Color = gradient.sample(value_normalized)
	
	number_pop_up.text = str(value)
	number_pop_up.global_position = position
	number_pop_up.modulate = color
	if value >= 40:
		number_pop_up.scale = Vector2.ONE * 2.0
		
	if value <= 10:
		number_pop_up.scale = Vector2.ONE * 1.0
	
	var main_node = get_tree().get_first_node_in_group("Main")
	var instance_parent = main_node
	if (parent):
		instance_parent = parent
	
	instance_parent.add_child(number_pop_up)
	number_pop_up.modulate = color * Color(1, 1, 1, 0)
	var tween = main_node.create_tween()

	tween.set_parallel(true)
	tween.tween_property(number_pop_up, "position:y", number_pop_up.position.y - 10, 0.2)
	tween.tween_property(number_pop_up, "modulate", color * Color(1, 1, 1, 1), 0.2)
	tween.tween_property(number_pop_up, "position:y", number_pop_up.position.y + 10, 0.2).set_delay(0.4)
	tween.tween_property(number_pop_up, "modulate", color * Color(1, 1, 1, 0), 0.2).set_delay(0.4)
	
