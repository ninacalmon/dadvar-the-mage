extends Control
@onready var paused_overlay: Control = %PausedOverlay

func _process(_delta):
	if Input.is_action_just_pressed("ui_cancel"):
		paused_overlay.visible = !paused_overlay.visible
		get_tree().paused = !get_tree().paused
