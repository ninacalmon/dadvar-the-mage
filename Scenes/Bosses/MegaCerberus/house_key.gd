extends Node2D

@onready var area_2d: Area2D = $Area2D
var following: bool = false
var player: Player
var speed_extra = 1.1
var collect_offset = 20

func _ready():
	self.area_2d.area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D):
	if area.name == "VpCollector":
		self.player = area.get_parent()
		self.following = true
		
func _process(delta: float) -> void:
	if not following:
		return
	var direction = (self.player.global_position + Vector2(0, Global.PLAYER_Y_SPRITE_OFFSET) - self.global_position).normalized()
	self.global_position += direction * self.player.stats_module.current_move_speed * speed_extra * delta
	
	if self.global_position.distance_to(self.player.global_position + Vector2(0, Global.PLAYER_Y_SPRITE_OFFSET)) <= collect_offset:
		collect()
		
func collect():
	self.queue_free()
	LevelTransition.change_scene_to("res://Cutscenes/game_cutscene.tscn", 1, 3)
