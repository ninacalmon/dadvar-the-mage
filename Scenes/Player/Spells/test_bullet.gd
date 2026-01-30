extends Sprite2D

@export var bullet_module: BulletModule
@onready var trail: CPUParticles2D = $Trail
@onready var magic_dust: CPUParticles2D = $MagicDust

var direction
var audio_track = preload("res://Sounds/city-castle-398832.mp3")

func _ready():
	$PointLight2D.energy = 1
	$PointLight2D.texture_scale = 0
	magic_dust.emitting = true
	# GAMBIARRA
	var stream_player = AudioStreamPlayer.new()
	stream_player.pitch_scale = randf_range(0.7, 1.7)
	stream_player.volume_db = -16
	stream_player.stream = audio_track
	stream_player.autoplay = true
	self.get_parent().add_child(stream_player)

	direction = bullet_module.get_bullet_move_direction(self.global_position, get_global_mouse_position())
	trail.direction = direction.normalized() * -1

	self.tree_exiting.connect(on_tree_exiting)

func _physics_process(delta: float) -> void:
	bullet_module.update_bullet_position(self, direction, delta)
	bullet_module.update_lifetime(delta)
	$PointLight2D.energy += 0.05
	if $PointLight2D.texture_scale < 1.3:
		$PointLight2D.texture_scale += 0.2

func on_tree_exiting():
	magic_dust.reparent(get_tree().get_first_node_in_group("Main"))
	magic_dust.finished.connect(func(): queue_free())
