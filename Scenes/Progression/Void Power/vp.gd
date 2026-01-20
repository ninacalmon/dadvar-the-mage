extends Area2D

@export var vp_amount = 10
@export var speed_extra = 1.1
@export var collect_offset = 20
var player: Player = null
var following = false


func _on_area_entered(area: Area2D) -> void:
	if area.name == "vp_collector":
		player = area.get_parent()
		following = true
		
func _process(delta: float) -> void:
	if not following or player == null:
		return
	var direction = (player.global_position - self.global_position).normalized()
	self.global_position += direction * player.stats_module.current_move_speed * speed_extra * delta
	
	if self.global_position.distance_to(player.global_position) <= collect_offset:
		collect()
		
func collect():
	player.stats_module.add_void_power(vp_amount)
	queue_free()
