extends Button

func _ready() -> void:
	self.pressed.connect(on_start_button_pressed)
	
func on_start_button_pressed():
	get_tree().change_scene_to_file("res://game.tscn")
