extends Node

var time_count: float = 0
@export var score_timer: Timer

@export var ghost_curve: Curve
@export var goblin_curve: Curve
@export var cerberus_curve: Curve
@export var goblin_boss_curve: Curve

@export var ghost: PackedScene
@export var goblin: PackedScene
@export var goblin_boss: PackedScene
@export var cerberus: PackedScene
@export var mega_cerberus: PackedScene
@export var player: Area2D

var mob = null
var has_megacerberus_spawned = false

@onready var music_system: Node = %MusicSystem

# WAVE1 0 - 0.35
# WAVE3 0.75 - 1.30
# WAVE 4 1.30 -

func _on_score_timer_timeout() -> void:
	time_count += 1
	if time_count != 0:
		var time_count_normalized = time_count / 100
		#Ghost
		$GhostSpawnRate.wait_time = 1 / ghost_curve.sample(time_count_normalized)
		$GhostSpawnRate.start()
		#Goblin
		$GoblinSpawnRate.wait_time = 1 / goblin_curve.sample(time_count_normalized)
		$GoblinSpawnRate.start()
		#Cerberus
		$CerberusSpawnRate.wait_time = 1 / cerberus_curve.sample(time_count_normalized)
		$CerberusSpawnRate.start()
		#Goblin Boss
		$GoblinBossSpawnRate.wait_time = 1 / goblin_boss_curve.sample(time_count_normalized)
		$GoblinBossSpawnRate.start()

func _ready() -> void:
	EventBus.mega_cerberus_is_dead.connect(on_mega_cerberus_death)
	score_timer.connect("timeout", _on_score_timer_timeout)

func _process(_delta: float) -> void:
	if time_count == 125:
		
		if has_megacerberus_spawned == false:
			self.music_system.start_boss_track(
				preload("res://Sounds/Vordt of the Boreal Valley.mp3"),
				2, # last song playing fade out time
				-10, # volume_db to play
			)

			$MegaCerberusSpawnRate.wait_time = 3
			$MegaCerberusSpawnRate.one_shot = true
			$MegaCerberusSpawnRate.start()
			has_megacerberus_spawned = true
			
func on_mega_cerberus_death():
	self.music_system.start_main_track(2)

func _on_ghost_spawn_rate_timeout() -> void:
	spawn_mob(ghost)
	
func _on_goblin_spawn_rate_timeout() -> void:
	spawn_mob(goblin)
	
func _on_cerberus_spawn_rate_timeout() -> void:
	spawn_mob(cerberus)
	
func _on_goblin_boss_spawn_rate_timeout() -> void:
	spawn_mob(goblin_boss)
	
func _on_mega_cerberus_spawn_rate_timeout() -> void:
	spawn_mob(mega_cerberus)
	

func spawn_mob(mob_to_spawn):
	if Global.CURRENT_MOBS_SPAWNED >= Global.MAXIMUM_MOBS_TO_SPAWN:
		return

	mob = mob_to_spawn.instantiate()
	mob.position = get_random_spawn_position()
	add_child(mob)
	Global.CURRENT_MOBS_SPAWNED += 1

func get_random_spawn_position() -> Vector2:
	const OFFSET_TO_OUT_OF_VIEWPORT = 1.5
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

func _on_player_player_death() -> void:
	time_count = 0
	$GhostSpawnRate.stop()
	$GoblinSpawnRate.stop()
	$CerberusSpawnRate.stop()
	$GoblinBossSpawnRate.stop()
