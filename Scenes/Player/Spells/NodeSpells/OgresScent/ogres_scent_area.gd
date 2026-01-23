class_name OgresScentArea extends Area2D

@export var damage_per_tick: float = 1
@export var tick_rate: float = 1

var targets_in_range: Array[Node] = []

func _ready():
	self.body_entered.connect(_on_body_entered)
	self.body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node2D):
	if Interface.node_implements_interface(body, Interface.Damageable):
		body.take_damage(self.damage_per_tick)
		targets_in_range.append(body)

func _on_body_exited(body: Node2D):
	targets_in_range.erase(body)

func setup_scent_area(damage: float, tick: float, radius: float):
	$CollisionShape2D.shape.radius = radius

	damage_per_tick = damage
	tick_rate = tick

	var timer = Timer.new()
	timer.wait_time = self.tick_rate
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_on_damage_tick_timeout)
	
	add_child(timer)
	
func _on_damage_tick_timeout():
	for target in targets_in_range:
		if is_instance_valid(target):
			target.take_damage(self.damage_per_tick)
			## MAY GET THIS EVENT HERE ON THE EVENT BUS
			##enemy_hit.emit(body)
