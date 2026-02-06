extends Area2D

@export var vp_amount = 10
@export var speed_extra = 1.1
@export var collect_offset = 20
@export var gradient: Gradient
var player: Player = null
var following = false
var minimum_hp = 20.0 # 20 is *currently* the minimum hp value. Not ideal.
var mob_hp: float

func _ready():
	self.vp_amount = mob_hp / 1.4
	var size = pow(mob_hp, 1.0 / 3.0) / pow(minimum_hp, 1.0 / 3.0)
	self.scale = Vector2.ONE * size
	var mob_hp_normalized = (mob_hp - 30.0) / (1000.0 - 30.0)
	var new_color = gradient.sample(mob_hp_normalized)
	$Sprite2D.modulate = new_color

func _on_area_entered(area: Area2D) -> void:
	if area.name == "VpCollector":
		player = area.get_parent()
		following = true
		
func _process(delta: float) -> void:
	if not following or player == null:
		return
	var direction = (player.global_position + Vector2(0, Global.PLAYER_Y_SPRITE_OFFSET) - self.global_position).normalized()
	self.global_position += direction * player.stats_module.current_move_speed * speed_extra * delta
	
	if self.global_position.distance_to(player.global_position + Vector2(0, Global.PLAYER_Y_SPRITE_OFFSET)) <= collect_offset:
		collect()
		
func collect():
	var stream_player = $collect_sound
	stream_player.play()
	stream_player.reparent(get_tree().get_first_node_in_group("Main"))
	stream_player.finished.connect(func ():
		stream_player.queue_free()
	)
	player.stats_module.add_void_power(vp_amount)
	queue_free()
