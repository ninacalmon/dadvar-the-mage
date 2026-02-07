extends Button

@onready var main_buttons: CenterContainer = %MainButtons
@onready var settings_container: CenterContainer = %SettingsContainer

func _ready():
	self.pressed.connect(_on_settings_button_pressed)

func _on_settings_button_pressed():
	self.settings_container.show()
	self.main_buttons.hide()
