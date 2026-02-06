extends TextureButton

@onready var hover = $RMaxDetailsText

func _ready() -> void:
	self.visibility_changed.connect(on_visibility_changed)

func _make_custom_tooltip(_for_text: String) -> Object:
	var obj = hover.duplicate()
	obj.show()
	return obj

func on_visibility_changed() -> void:
	self.rotation_degrees = self.rotation_degrees + randi_range(-10, 10)
