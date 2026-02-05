extends Sprite2D
var implements = Interface.MobProjectile

@export var bullet_module: BulletModule

@onready var player = get_tree().get_nodes_in_group("PlayerGroup")[0]
var direction
var audio_track = preload("res://Sounds/city-castle-398832.mp3")

func _ready():
	$PointLight2D.energy = 0
	self.scale = Vector2(0.1, 0.1)
	# GAMBIARRA
	var stream_player = AudioStreamPlayer.new()
	stream_player.pitch_scale = randf_range(0.7, 1.4)
	stream_player.volume_db = randf_range(-20, -22)
	stream_player.stream = audio_track
	stream_player.autoplay = true
	get_parent().add_child(stream_player)
	
	direction = bullet_module.get_bullet_move_direction(self.position, player.global_position)

func _physics_process(delta: float) -> void:
	bullet_module.update_bullet_position(self, direction, delta)
	bullet_module.update_lifetime(delta)
	if self.scale < Vector2(2, 2):
		self.scale += Vector2(0.1, 0.1)
	if $PointLight2D.energy < 2:
		$PointLight2D.energy += 0.5
