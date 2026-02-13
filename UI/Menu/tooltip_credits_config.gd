extends LinkButton

@onready var hover = $TooltipText

func _make_custom_tooltip(_for_text: String) -> Object:
	var obj = hover.duplicate()
	obj.show()
	return obj
