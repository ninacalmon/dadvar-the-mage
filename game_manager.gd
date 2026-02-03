extends Node

var is_player_dead = false
@onready var player: Player = %player/PlayerArea
@onready var paused_overlay: Control = %PausedOverlay
@onready var restart_overlay: Control = %RestartOverlay
@onready var book_animation: AnimatedSprite2D = %BookAnimation


func _ready() -> void:
	player.player_death.connect(_on_player_player_death)

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		if !book_animation.visible:
			paused_overlay.visible = !paused_overlay.visible
			get_tree().paused = !get_tree().paused
		
		
	if Input.is_action_just_pressed("Restart") and is_player_dead == true:
			get_tree().reload_current_scene()
			restart_overlay.hide()
		
func _on_player_player_death() -> void:
	is_player_dead = true
	get_tree().paused = !get_tree().paused
	restart_overlay.show()
