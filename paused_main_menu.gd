extends Button

func _ready() -> void:
	self.pressed.connect(on_main_menu_button_pressed)
	
func on_main_menu_button_pressed():
	var tree = get_tree()
	tree.paused = !tree.paused
	tree.change_scene_to_file("res://UI/Menu/main_menu.tscn")
