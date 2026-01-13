extends Sprite2D

@export var bullet_module: BulletModule

var direction

func _ready():
	$PointLight2D.energy = 1
	$PointLight2D.texture_scale = 0
	$CPUParticles2D.emitting = true
	direction = bullet_module.get_bullet_move_direction(self.position, get_global_mouse_position())

func _physics_process(delta: float) -> void:
	bullet_module.update_bullet_position(self, direction, delta)
	bullet_module.update_lifetime(delta)
	$PointLight2D.energy += 0.05
	if $PointLight2D.texture_scale < 1.3:
		$PointLight2D.texture_scale += 0.2
