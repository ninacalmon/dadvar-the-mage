extends CharacterBody2D

@export_group("Exports")
@export var stats_module: StatsModule

@export_subgroup("Wobble")
@export var frequency := 1.0
@export var amplitude := PI * 0.25
var wobble_time := 0.0


@onready var player_sprite: AnimatedSprite2D = $PlayerArea/PlayerSprite
@onready var wand_tip: Node2D = $WandTip

const WAND_TIP_POSITION_X_ABSOLUTE = 63

func wobble(delta: float):
	wobble_time += delta
	player_sprite.rotation = sin(wobble_time * frequency) * amplitude
	
func _process(_delta: float) -> void:
	if self.global_position.y == -1700:
		self.stats_module.base_move_speed = 80

func _physics_process(_delta: float) -> void:
	var direction = Vector2.ZERO
	if Input.is_action_pressed("Right"):
		direction.x += 1
	if Input.is_action_pressed("Left"):
		direction.x -= 1
	if Input.is_action_pressed("Down"):
		direction.y += 1
	if Input.is_action_pressed("Up"):
		direction.y -= 1

	if direction.length() > 0:
		player_sprite.animation = "idle"
		player_sprite.flip_h = direction.x < 0

		wand_tip.position.x = -WAND_TIP_POSITION_X_ABSOLUTE if direction.x < 0 else WAND_TIP_POSITION_X_ABSOLUTE
		wobble(_delta)
		velocity = direction.normalized() * stats_module.current_move_speed 
	else:
		player_sprite.animation = "idle"
		player_sprite.rotation = 0

	move_and_slide()
	velocity = Vector2.ZERO
	
	#var direction = mob.global_position.direction_to(player.global_position)
	#mob.velocity = direction * movement_speed
	#mob.move_and_slide()
