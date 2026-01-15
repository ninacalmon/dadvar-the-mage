extends Node

@export var ghost: PackedScene
@export var goblin: PackedScene
@export var goblin_boss: PackedScene
@export var player: Area2D

var mob = 0
var wave_count = 1
var wave1_duration = 20
var wave2_duration = 30
var wave3_duration = 1000

func _ready() -> void:
	if wave_count == 1:
		print(wave_count)
		$WaveTimer.wait_time = wave1_duration
		$WaveTimer.start()
		
		$GhostSpawnRate.wait_time = 0.5
		$GhostSpawnRate.start()
	
func _on_wave_timer_timeout() -> void:
	wave_count += 1
	print(wave_count)
	if wave_count == 2:
		$WaveTimer.wait_time = wave2_duration
		$WaveTimer.one_shot = true
		$GoblinSpawnRate.start()
		
		$GhostSpawnRate.wait_time = 3
		$GoblinSpawnRate.wait_time = 0.3

	if wave_count == 3:
		$WaveTimer.wait_time = wave3_duration
		$GhostSpawnRate.wait_time = randf_range(5, 10)
		$GoblinSpawnRate.wait_time = 0.3
		$GoblinBossSpawnRate.wait_time = 10
		$GoblinBossSpawnRate.start()

func _on_ghost_spawn_rate_timeout() -> void:
	spawn_mob(ghost)
	
func _on_goblin_spawn_rate_timeout() -> void:
	spawn_mob(goblin)
	
func _on_goblin_boss_spawn_rate_timeout() -> void:
	spawn_mob(goblin_boss)
	

	
	
func spawn_mob(mob):
	mob = mob.instantiate()
	mob.position = get_random_spawn_position()
	add_child(mob)
	

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
