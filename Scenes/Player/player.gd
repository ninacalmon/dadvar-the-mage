extends Area2D
signal hit

@export var health = 100
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
	rotation = sin(Time.get_ticks_msec() * frequency) * amplitude
			
func _physics_process(delta: float) -> void:
	shoot_cooldown = max(shoot_cooldown - delta, 0)
	if Input.is_action_pressed("shoot") and shoot_cooldown <= 0:
		var bullet = bullet.instantiate()
		bullet.global_position = $WandTip.global_position

		#bullet.shoot(get_global_mouse_position())
		get_parent().add_child(bullet)
		shoot_cooldown = player_shoot_cooldown


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # player's inicial movement set to zero.
	if Input.is_action_pressed("Right"):
		velocity.x += 1
	if Input.is_action_pressed("Left"):
		velocity.x -= 1
	if Input.is_action_pressed("Down"):
		velocity.y += 1
	if Input.is_action_pressed("Up"):
		velocity.y -= 1

	#if velocity.length() > 0:
		#velocity = velocity.normalized() * speed # normalizing vertical movement.
		#
		#$AnimatedSprite2D.play() # animating.
	#else:
		#$AnimatedSprite2D.stop() #stopping animation.
		
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
		#$AnimatedSprite2D.rotation = velocity.angle() + PI/2


	position += velocity * delta # updating position.

	## Choosing animation.
	#if velocity.x != 0:
		#$AnimatedSprite2D.animation = "walk"
		#$AnimatedSprite2D.flip_v = false
		#$AnimatedSprite2D.flip_h = velocity.x < 0
	#elif velocity.y != 0:
			#$AnimatedSprite2D.animation = "up"
			#$AnimatedSprite2D.flip_v = velocity.y > 0
			
	# Collision
func _on_body_entered(body: Node2D) -> void:
	hit.emit()
	
func player_death():
	hide()
	$CollisionShape2D.set_deferred("disabled", true)
