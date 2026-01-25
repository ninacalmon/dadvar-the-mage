extends Node

@export var consumable1: PackedScene
@export var consumable2: PackedScene
@export var player: Area2D

var consumable_options: Array[PackedScene] = [consumable1, consumable2]

func _ready() -> void:
	$ConsumableSpawnTimer.start()
	
func _on_consumable_spawn_timer_timeout() -> void:
	var chance = randi_range(1, 5)
	print(chance)
	if chance == 1:
		var chosen_consumable = [consumable1, consumable2].pick_random()
		var consumable = chosen_consumable.instantiate()
		consumable.position = get_random_spawn_position()
		add_child(consumable)
		

## MAKE THIS FUNCTI0N A RESOURCE vvvv
func get_random_spawn_position() -> Vector2:
	const OFFSET_TO_OUT_OF_VIEWPORT = 1.3
	var random_offset = randf_range(1.2, 1.8)
	var viewport = Vector2(get_viewport().size * OFFSET_TO_OUT_OF_VIEWPORT) + Vector2(random_offset, random_offset)

	var top_left = Vector2(player.global_position.x - viewport.x / 2, player.global_position.y - viewport.y/2) 
	var top_right = Vector2(player.global_position.x + viewport.x / 2, player.global_position.y - viewport.y/2)
	var bottom_left = Vector2(player.global_position.x - viewport.x / 2, player.global_position.y + viewport.y/2)
	var bottom_right = Vector2(player.global_position.x + viewport.x / 2, player.global_position.y + viewport.y/2)
	
	var possible_positions_array = ["up", "down", "left", "right"]
	
	var pos_1 = Vector2.ZERO
	var pos_2 = Vector2.ZERO
	
	match possible_positions_array.pick_random():
		"up":
			pos_1 = top_left
			pos_2 = top_right
		"down":
			pos_1 = bottom_left
			pos_2 = bottom_right
		"left":
			pos_1 = top_left
			pos_2 = bottom_left
		"right":
			pos_1 = top_right
			pos_2 = bottom_right
			
	var x_spawn = randf_range(pos_1.x, pos_2.x)
	var y_spawn = randf_range(pos_1.y, pos_2.y)

	return Vector2(x_spawn, y_spawn)
	
