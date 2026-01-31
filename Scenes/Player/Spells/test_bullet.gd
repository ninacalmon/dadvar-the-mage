extends Sprite2D

@export var bullet_module: BulletModule
@onready var trail: CPUParticles2D = $Trail
@onready var magic_dust: CPUParticles2D = $MagicDust
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var point_light_2d: PointLight2D = $PointLight2D

var direction
var audio_track = preload("res://Sounds/city-castle-398832.mp3")

func _ready():
	point_light_2d.energy = 1
	point_light_2d.texture_scale = 0
	magic_dust.emitting = true

	audio_stream_player.pitch_scale = randf_range(0.7, 1.7)
	audio_stream_player.reparent(get_tree().get_first_node_in_group("Main"))
	## NOTE TO REMEMBER FOREVER: NEVER CALL QUEUE FREE WITHOUT SPECIFYING WHO THE FUCK IS BEING QUEUED FREE vvv
	audio_stream_player.finished.connect(func(): audio_stream_player.queue_free())

	direction = bullet_module.get_bullet_move_direction(self.global_position, get_global_mouse_position())
	trail.direction = direction.normalized() * -1

	self.tree_exiting.connect(on_tree_exiting)

func _physics_process(delta: float) -> void:
	bullet_module.update_bullet_position(self, direction, delta)
	bullet_module.update_lifetime(delta)
	point_light_2d.energy += 0.05

	if point_light_2d.texture_scale < 1.3:
		point_light_2d.texture_scale += 0.2

func on_tree_exiting():
	var main_node = get_tree().get_first_node_in_group("Main")
	magic_dust.reparent(main_node)
	magic_dust.finished.connect(func(): magic_dust.queue_free())
