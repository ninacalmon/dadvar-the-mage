extends RichTextLabel

var time_count = 0
@onready var score_timer: Timer = %ScoreTimer

func _ready():
	self.show()
	score_timer.connect("timeout", _on_score_timer_timeout)

func _on_score_timer_timeout() -> void:
	time_count += 1
	self.text = str(seconds_to_mmss(time_count))

func seconds_to_mmss(total_seconds: int) -> String:
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	return "%02d:%02d" % [minutes, seconds]
