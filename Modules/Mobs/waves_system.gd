extends Node2D

var time_count: float = 0
@export var score_timer: Timer

@export var ghost_curve: Curve
@export var goblin_curve: Curve
@export var skeleton_curve: Curve
@export var cerberus_curve: Curve
@export var gargoyle_curve: Curve

@export var ghost: PackedScene
@export var goblin: PackedScene
@export var goblin_boss: PackedScene
@export var cerberus: PackedScene
@export var mega_cerberus: PackedScene
@export var gargoyle: PackedScene
@export var banshee: PackedScene
@export var skeleton: PackedScene
@export var seraphim: PackedScene
@export var player: Area2D

@onready var music_system: MusicSystem = %MusicSystem
@onready var boss_spawn_timer: Timer = $BossSpawnTimer
@onready var skeleton_spawn_rate: Timer = $SkeletonSpawnRate
@onready var banshee_spawn_rate: Timer = $BansheeSpawnRate

var boss_queue: Array[PackedScene] = []
var current_active_boss: Node2D = null
var is_banshee_attack: bool = false

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
		#Gargoyle
		$GargoyleSpawnRate.wait_time = 1 / gargoyle_curve.sample(time_count_normalized)
		$GargoyleSpawnRate.start()
		#Skeleton
		skeleton_spawn_rate.wait_time = 1 / skeleton_curve.sample(time_count_normalized)
		skeleton_spawn_rate.start()

	#if time_count == 10:
		#is_banshee_attack = true
	if time_count == 150:
		self.boss_queue.append(self.goblin_boss)
	if time_count == 330:
		self.boss_queue.append(self.mega_cerberus)
	if time_count == 590:
		self.boss_queue.append(self.seraphim)

func _ready() -> void:
	EventBus.mega_cerberus_death.connect(_on_mega_cerberus_death)
	EventBus.enemy_died.connect(_on_enemy_died_received)
	score_timer.connect("timeout", _on_score_timer_timeout)
	boss_spawn_timer.timeout.connect(_boss_spawn_timer_timeout)
	skeleton_spawn_rate.timeout.connect(_on_skeleton_spawn_rate_timeout)

func _on_ghost_spawn_rate_timeout() -> void:
	var spawn_position = self.get_random_spawn_position()
	var horde_chance = randi_range(1, 10)
	if horde_chance <= 2:
		var spawn_quantity = randi_range(3, 5)
		for _sp in range(spawn_quantity):
			spawn_mob(ghost, spawn_position + Vector2(randi_range(10, 50), randi_range(10, 50)))
	else:
		spawn_mob(ghost, spawn_position)
	
func _on_goblin_spawn_rate_timeout() -> void:
	var spawn_position = self.get_random_spawn_position()
	var horde_chance = randi_range(1, 10)
	if horde_chance <= 2:
		var spawn_quantity = randi_range(3, 5)
		for _sp in range(spawn_quantity):
			spawn_mob(goblin, spawn_position + Vector2(randi_range(10, 50), randi_range(10, 50)))
	else:
		spawn_mob(goblin, spawn_position)

func _on_cerberus_spawn_rate_timeout() -> void:
	var spawn_position = self.get_random_spawn_position()
	spawn_mob(cerberus, spawn_position)

func _on_goblin_boss_spawn_rate_timeout() -> void:
	var spawn_position = self.get_random_spawn_position()
	spawn_mob(goblin_boss, spawn_position)

func _on_gargoyle_spawn_rate_timeout() -> void:
	var spawn_position = self.get_random_spawn_position()
	spawn_mob(gargoyle, spawn_position)
	
func _on_skeleton_spawn_rate_timeout() -> void:
	var spawn_position = self.get_random_spawn_position()
	spawn_mob(skeleton, spawn_position)
	
func _on_banshee_spawn_rate_timeout() -> void:
	var horde_chance = randi_range(1, 5)

	if time_count >= 450:
		is_banshee_attack = false

	if !is_banshee_attack:
		banshee_spawn_rate.wait_time = randi_range(20, 40)
	else:
		banshee_spawn_rate.wait_time = randi_range(1, 10)
		horde_chance = randi_range(1, 3)

	if horde_chance <= 2:
		var spawn_quantity = randi_range(2, 4)
		for _sp in range(spawn_quantity):
			var spawn_position = self.get_random_spawn_position()
			spawn_mob(banshee, spawn_position + Vector2(10 * _sp, 10 * _sp))
	else:
		var spawn_position = self.get_random_spawn_position()
		spawn_mob(banshee, spawn_position)

func _on_mega_cerberus_death():
	is_banshee_attack = true

func spawn_mob(mob_to_spawn: PackedScene, spawn_position: Vector2) -> Node2D:
	if Global.CURRENT_MOBS_SPAWNED >= Global.MAXIMUM_MOBS_TO_SPAWN:
		return

	var mob = mob_to_spawn.instantiate()
	mob.position = spawn_position
	add_child(mob)

	Global.CURRENT_MOBS_SPAWNED += 1
	
	return mob

func _boss_spawn_timer_timeout():
	if current_active_boss or boss_queue.size() == 0:
		return

	var boss_soundtrack_to_play: AudioStream = preload("res://Sounds/Vordt of the Boreal Valley.mp3")

	if self.music_system.currently_playing_soundtrack != boss_soundtrack_to_play:
		self.music_system.start_boss_track(
			boss_soundtrack_to_play,
			2, # last song playing fade out time
			-10, # volume_db to play
		)

	var boss_to_spawn: PackedScene = self.boss_queue.pop_front()
	var spawn_position: Vector2 = get_random_spawn_position()
	var boss_spawned_instance = spawn_mob(boss_to_spawn, spawn_position)

	self.current_active_boss = boss_spawned_instance

func _on_enemy_died_received(enemy_mob_behaviour: MobBehaviourModule) -> void:
	if enemy_mob_behaviour.mob == current_active_boss:
		current_active_boss = null
		if self.boss_queue.size() == 0:
			self.music_system.start_main_track(2)

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
	$GargoyleSpawnRate.stop()
	skeleton_spawn_rate.stop()
	boss_spawn_timer.stop()
