extends DirectionalLight2D
@onready var player: CharacterBody2D = %PlayerBody2d


func _process(_delta: float) -> void:
	if player.global_position.y <= -1300:
		var current_energy = self.energy
		var tween = get_tree().create_tween()
		tween.tween_property(self, "energy", 0.1, 8).from(current_energy)
