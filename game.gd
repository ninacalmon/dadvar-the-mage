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

## Prepares and set for reload.
func _on_player_player_death() -> void:
	$ScoreTimer.stop()
	print(time_count)
	get_tree().reload_current_scene()
