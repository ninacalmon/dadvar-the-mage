extends RichTextLabel

var time_count = 0
@export var score_timer: Timer

func _ready():
	score_timer.connect("timeout", _on_score_timer_timeout)

func _on_score_timer_timeout() -> void:
	time_count += 1
	self.text = str(time_count)
	
	
