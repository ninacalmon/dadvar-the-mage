extends Area2D
signal player_death

@export var health_module: HealthModule
@export var speed = 400
@export var bullet: PackedScene
@export var player_shoot_cooldown: float
var shoot_cooldown = 0

func start(pos):
	position = pos
	show()
	$CollisionShape2D.disabled = false
	
@export var frequency := 1.0
@export var amplitude := PI * 0.25
func wobble():
	$AnimatedSprite2D.rotation = sin(Time.get_ticks_msec() * frequency) * amplitude
			
func _physics_process(delta: float) -> void:
	shoot_cooldown = max(shoot_cooldown - delta, 0)
	if Input.is_action_pressed("shoot") and shoot_cooldown <= 0:
		var bullet = bullet.instantiate()
		bullet.global_position = $WandTip.global_position

		get_parent().add_child(bullet)
		shoot_cooldown = player_shoot_cooldown

func _process(delta: float) -> void:
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("Right"):
		velocity.x += 1
	if Input.is_action_pressed("Left"):
		velocity.x -= 1
	if Input.is_action_pressed("Down"):
		velocity.y += 1
	if Input.is_action_pressed("Up"):
		velocity.y -= 1

	if velocity.length() > 0:
		$AnimatedSprite2D.animation = "idle"
		$AnimatedSprite2D.flip_h = velocity.x < 0

		const WAND_TIP_POSITION_X_ABSOLUTE = 63
		$WandTip.position.x = -WAND_TIP_POSITION_X_ABSOLUTE if velocity.x < 0 else WAND_TIP_POSITION_X_ABSOLUTE
		wobble()
		velocity = velocity.normalized() * speed
	else:
		$AnimatedSprite2D.animation = "idle"
		$AnimatedSprite2D.rotation = 0
		
	position += velocity * delta # updating position.

	# Collision
func _on_body_entered(body: Node2D) -> void:
	if Interface.node_implements_interface(body, Interface.Mob):
		var behaviour: MobBehaviourModule = body.behaviour_module
		var current_health = health_module.get_health()
		health_module.set_health(current_health - behaviour.damage)

func _on_player_health_health_depleted() -> void:
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
	player_death.emit()
