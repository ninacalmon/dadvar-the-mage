extends Node

@export var mob_scene: PackedScene
@export var mob_scene2: PackedScene
@export var mob_scene3: PackedScene
@export var player: Area2D

var time_count

func _ready() -> void:
	new_game()
	
func new_game():
	time_count = 0
	$player.start($StartPosition.position)
	$StartTimer.start()
	
func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()

func _on_score_timer_timeout() -> void:
	time_count += 1
	print(time_count)
	if time_count == 20:
		var mob = mob_scene3.instantiate()
		
		mob.position = get_random_spawn_position()
		add_child(mob)
	
func _on_mob_timer_timeout() -> void:
	var mob
	var random_number = randi_range(1, 100)
	if random_number <= 30 :
		mob = mob_scene.instantiate()
	elif random_number > 30 and random_number < 101 :
		mob = mob_scene2.instantiate()
		
	
	# Create a new instance of a Mob.

	
	# Choose random spawn location on Path2D.
	# var mob_spawn_location = $player/CameraMobPath/CameraMobSpawnLocation
	# print("Mob spawn location:", mob_spawn_location.position)
	# mob_spawn_location.progress_ratio = randf()
	mob.position = get_random_spawn_position()
	
	# Set the mob's direction perpendicular to the path location.
	# var direction = mob_spawn_location.rotation + PI / 2
	# + Some randomness.
	# direction += randf_range(-PI / 4, PI / 4)
	# mob.rotation = direction
	
	# Choose velocity.
	# var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	# mob.linear_velocity = velocity
	
	# Spawn mob into the Game scene (finally).
	add_child(mob)
	#
func get_random_spawn_position() -> Vector2:
	var random_offset = randf_range(1.2, 1.8)
	var viewport = Vector2(get_viewport().size) + Vector2(random_offset, random_offset)

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

func _on_player_player_death() -> void:
	$ScoreTimer.stop()
	$MobTimer.stop()
	print(time_count)
	get_tree().reload_current_scene()
