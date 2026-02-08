extends TextureProgressBar
class_name HealthBar

@onready var health: HealthModule
@export var custom_label: RichTextLabel

func set_health_bar_target(target: Node2D):
	if custom_label:
		custom_label.text = Global.prettify_class_name(target.get_script().get_global_name())

	var health_mod: HealthModule = target.find_child("HealthModule", true)
	assert(health_mod != null, "Health bar target passed in do not have a health module as child")

	self.health = health_mod
	self.max_value = self.health.get_max_health()
	self.value = self.health.get_health()
	# This here connects to the health_changed signal emitted by the health module.
	# This is the equivalent of using the interface, but the function connected does not
	# show the green arrow on the side
	self.health.health_changed.connect(_update_bar)
	self.health.max_health_changed.connect(_update_max_bar_value)

func _update_bar(_diff: float) -> void:
	self.ease_tween_health_bar("value", self.health.get_health, 0.3)

func _update_max_bar_value(_diff: float) -> void:
	self.value = self.health.get_health()

	self.ease_tween_health_bar("max_value", self.health.get_max_health, 0.3)

func ease_tween_health_bar(property: String, end_value: Callable, ease_time: float):
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(
		self,
		property,
		end_value.call(),
		ease_time
	)
