extends Node2D

signal wave_changed(wave: int)

var wave_time_count: float = 0
@export var score_timer: Timer
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
@onready var cerberus_spawn_rate: Timer = $CerberusSpawnRate
@onready var banshee_spawn_rate: Timer = $BansheeSpawnRate
@onready var new_wave_timer: Timer = $NewWaveTimer

#region curves
@export var no_spawn_curve: Curve

@export var low_spawn_curve: Curve
@export var medium_spawn_curve: Curve
@export var high_spawn_curve: Curve

@export var endless_low_spawn_curve: Curve
@export var endless_medium_spawn_curve: Curve
@export var endless_high_spawn_curve: Curve
#endregion


var boss_queue: Array[PackedScene] = []
var current_active_boss: Node2D = null
var is_banshee_attack: bool = false

enum PossibleMobs {
	GHOST,
	GOBLIN,
	SKELETON,
	CERBERUS,
	GARGOYLE
}

const GOBLIN_BOSS_WAVE = 5
const MEGA_CERBERUS_WAVE = 9
const SERAPHIM_WAVE = 13

@onready var current_ghost_curve = no_spawn_curve
@onready var current_goblin_curve = no_spawn_curve
@onready var current_skeleton_curve = no_spawn_curve
@onready var current_cerberus_curve = no_spawn_curve
@onready var current_gargoyle_curve = no_spawn_curve

var current_wave: int = 1

@onready var waves_dictionary: Dictionary[int, Dictionary] = {
	1: {
		PossibleMobs.GHOST: low_spawn_curve
	},
	2: {
		PossibleMobs.GHOST: medium_spawn_curve,
	},
	3: {
		PossibleMobs.GHOST: medium_spawn_curve,
		PossibleMobs.GOBLIN: low_spawn_curve
	},
	4: {
		PossibleMobs.GOBLIN: medium_spawn_curve
	},
	GOBLIN_BOSS_WAVE: { #Goblin Boss Wave
		PossibleMobs.GOBLIN: endless_low_spawn_curve,
		PossibleMobs.SKELETON: endless_low_spawn_curve
	},
	6: {
		PossibleMobs.SKELETON: high_spawn_curve
	},
	7: {
		PossibleMobs.SKELETON: medium_spawn_curve,
		PossibleMobs.CERBERUS: medium_spawn_curve
	},
	8: {
		PossibleMobs.CERBERUS: medium_spawn_curve,
		PossibleMobs.GHOST: high_spawn_curve
	},
	MEGA_CERBERUS_WAVE: { #Mega Ceberus Wave
		PossibleMobs.GHOST: endless_high_spawn_curve
	},
	10: { #Banshee Attack
		PossibleMobs.GHOST: low_spawn_curve,
		PossibleMobs.GARGOYLE: medium_spawn_curve
	},
	11: { #Banshee Attack
		PossibleMobs.SKELETON: high_spawn_curve,
		PossibleMobs.GARGOYLE: medium_spawn_curve
	},
	12: { #Banshee Attack
		PossibleMobs.SKELETON: high_spawn_curve,
		PossibleMobs.GARGOYLE: high_spawn_curve
	},
	SERAPHIM_WAVE: { #Seraphim Wave
		PossibleMobs.GHOST: endless_high_spawn_curve,
		PossibleMobs.SKELETON: endless_high_spawn_curve
	}
}

func _ready() -> void:
	self.wave_changed.connect(_on_wave_changed)

	EventBus.enemy_died.connect(_on_enemy_died_received)

	score_timer.connect("timeout", _on_score_timer_timeout)
	boss_spawn_timer.timeout.connect(_boss_spawn_timer_timeout)
	new_wave_timer.timeout.connect(_on_new_wave_timer_timeout)
	skeleton_spawn_rate.timeout.connect(_on_skeleton_spawn_rate_timeout)
	cerberus_spawn_rate.timeout.connect(_on_cerberus_spawn_rate_timeout)

	var current_wave_dictonary = waves_dictionary.get(current_wave, {})

	for mob: PossibleMobs in current_wave_dictonary:
		var mob_name = (PossibleMobs.keys()[mob]).to_lower()
		var mob_curve: Curve = current_wave_dictonary[mob]
		var curve_variable_to_update = "current_%s_curve" % mob_name
		self.set(curve_variable_to_update, mob_curve)

func _on_new_wave_timer_timeout():
	self.set_current_wave(self.current_wave + 1)

	var current_wave_dictonary = waves_dictionary.get(self.current_wave, null)
	## If there are no more waves planned, then just stick with the last one
	if (current_wave_dictonary == null):
		return

	## Every wave reset all mobs to no_spawn_curve
	for mob in PossibleMobs.values():
		var mob_name = (PossibleMobs.keys()[mob]).to_lower()
		var curve_variable := "current_%s_curve" % mob_name
		self.set(curve_variable, no_spawn_curve)

	## For the ones we want on this wave, override the no_spawn_curve
	for mob: PossibleMobs in current_wave_dictonary:
		var mob_name = (PossibleMobs.keys()[mob]).to_lower()
		var mob_curve = current_wave_dictonary[mob]
		var curve_variable_to_update = "current_%s_curve" % mob_name
		self.set(curve_variable_to_update, mob_curve)
	
	wave_time_count = 0

func _on_score_timer_timeout() -> void:
	wave_time_count += 1
	if wave_time_count != 0:
		#Ghost
		$GhostSpawnRate.wait_time = 1 / current_ghost_curve.sample(wave_time_count)
		$GhostSpawnRate.start()
		#Goblin
		$GoblinSpawnRate.wait_time = 1 / current_goblin_curve.sample(wave_time_count)
		$GoblinSpawnRate.start()
		#Skeleton
		skeleton_spawn_rate.wait_time = 1 / current_skeleton_curve.sample(wave_time_count)
		skeleton_spawn_rate.start()
		#Cerberus
		cerberus_spawn_rate.wait_time = 1 / current_cerberus_curve.sample(wave_time_count)
		cerberus_spawn_rate.start()
		#Gargoyle
		$GargoyleSpawnRate.wait_time = 1 / current_gargoyle_curve.sample(wave_time_count)
		$GargoyleSpawnRate.start()
		
func _on_wave_changed(wave: int):
	if wave == self.GOBLIN_BOSS_WAVE:
		self.boss_queue.append(self.goblin_boss)
	if wave == self.MEGA_CERBERUS_WAVE:
		self.boss_queue.append(self.mega_cerberus)
	if wave == self.SERAPHIM_WAVE:
		self.boss_queue.append(self.seraphim)

	if wave == 10:
		self.is_banshee_attack = true
	if wave == 12:
		self.is_banshee_attack = false


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

func _on_goblin_boss_spawn_rate_timeout() -> void:
	var spawn_position = self.get_random_spawn_position()
	spawn_mob(goblin_boss, spawn_position)

func _on_gargoyle_spawn_rate_timeout() -> void:
	var spawn_position = self.get_random_spawn_position()
	spawn_mob(gargoyle, spawn_position)
	
func _on_skeleton_spawn_rate_timeout() -> void:
	var spawn_position = self.get_random_spawn_position()
	spawn_mob(skeleton, spawn_position)

func _on_cerberus_spawn_rate_timeout() -> void:
	var spawn_position = self.get_random_spawn_position()
	spawn_mob(cerberus, spawn_position)
	
func _on_banshee_spawn_rate_timeout() -> void:
	var horde_chance = randi_range(1, 5)

	if !self.is_banshee_attack:
		banshee_spawn_rate.wait_time = randi_range(20, 40)
	else:
		banshee_spawn_rate.wait_time = randi_range(1, 3)
		horde_chance = 3

	if horde_chance <= 2:
		var spawn_quantity = randi_range(2, 4)
		for _sp in range(spawn_quantity):
			var spawn_position = self.get_random_spawn_position()
			spawn_mob(banshee, spawn_position + Vector2(10 * _sp, 10 * _sp))
	else:
		var spawn_position = self.get_random_spawn_position()
		spawn_mob(banshee, spawn_position)

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
	self.new_wave_timer.stop()

func _on_enemy_died_received(enemy_mob_behaviour: MobBehaviourModule) -> void:
	if enemy_mob_behaviour.mob == current_active_boss:
		current_active_boss = null
		if self.boss_queue.size() == 0:
			self.music_system.start_main_track(2)
			self.new_wave_timer.start()
			self._on_new_wave_timer_timeout()

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
	wave_time_count = 0
	$GhostSpawnRate.stop()
	$GoblinSpawnRate.stop()
	$CerberusSpawnRate.stop()
	$GargoyleSpawnRate.stop()
	skeleton_spawn_rate.stop()
	cerberus_spawn_rate.stop()
	boss_spawn_timer.stop()

func set_current_wave(value: int):
	if value == self.current_wave:
		return
	self.current_wave = value
	self.wave_changed.emit(value)
