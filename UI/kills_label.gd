extends RichTextLabel

var kill_count: int = 0

func _ready() -> void:
	EventBus.enemy_died.connect(_on_enemy_death)
	
func _on_enemy_death(_enemy) -> void:
	kill_count += 1
	self.text = "%.0f [b]A[/b]" % kill_count
