extends ProgressBar

@export var player: Player
@onready var level_label: RichTextLabel = $LevelLabel

func _ready():
	max_value = player.stats_module.vp_needed
	value = 0
	EventBus.vp_changed.connect(update_current_vp)
	EventBus.player_level_up.connect(update_maxmin_values)

func update_current_vp(_current_player_vp: float):
	const EASE_TIME = 0.3

	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		"value",
		player.stats_module.void_power,
		EASE_TIME
	)

func update_maxmin_values(level: int):
	self.max_value = player.stats_module.vp_needed
	self.min_value = player.stats_module.void_power
	level_label.text = "lvl %d" % level
