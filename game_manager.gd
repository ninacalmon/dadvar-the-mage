extends Node

var is_player_dead = false
@onready var player: Player = %player/PlayerArea


func _ready() -> void:
	player.player_death.connect(_on_player_player_death)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = !get_tree().paused
		
	if Input.is_action_just_pressed("Restart") and is_player_dead == true:
			get_tree().reload_current_scene()
		
func _on_player_player_death() -> void:
	is_player_dead = true
	get_tree().paused = !get_tree().paused
