class_name OgresScentArea extends Area2D

@export var damage_per_tick: float = 1
@export var tick_rate: float = 1
@onready var point_light_2d: PointLight2D = $PointLight2D


var targets_in_range: Array[Node] = []
var oscilate_time: float
var frequency = 4
var max_oscilate_value = 0.8
var min_oscilate_value = 0.4

func _ready():
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)
	

func oscilate_energy(delta: float):
	var mid_value = (max_oscilate_value + min_oscilate_value) / 2
	var amplitude = (max_oscilate_value - min_oscilate_value) / 2

	oscilate_time += (delta * TAU) / frequency
	point_light_2d.energy = sin(oscilate_time) * amplitude + mid_value
	
func _process(delta: float) -> void:
	oscilate_energy(delta)

func _on_body_entered(body: Node2D):
	if Interface.node_implements_interface(body, Interface.Damageable):
		targets_in_range.append(body)

func _on_body_exited(body: Node2D):
	targets_in_range.erase(body)

func setup_scent_area(damage: float, tick: float, area_scale: Vector2):
	const POINT_LIGHT_SHAPE_RATIO = 3.5
	self.position.y = Global.PLAYER_Y_SPRITE_OFFSET
	$CollisionShape2D.scale = area_scale
	$PointLight2D.scale = area_scale / POINT_LIGHT_SHAPE_RATIO
	

	damage_per_tick = damage
	print("TICK RECEIGVED ", tick)
	tick_rate = tick

	var timer = Timer.new()
	timer.wait_time = self.tick_rate
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_on_damage_tick_timeout)

	add_child(timer)
	
func _on_damage_tick_timeout():
	print("TICKKKKKK ", )
	for target in targets_in_range:
		if is_instance_valid(target):
			target.take_damage(self.damage_per_tick)
			## MAY GET THIS EVENT HERE ON THE EVENT BUS
			##enemy_hit.emit(body)
