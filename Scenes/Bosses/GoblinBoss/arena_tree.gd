extends StaticBody2D
class_name ArenaTree

@onready var tree_sprite: Sprite2D = $TreeSprite
@onready var emerging_sound: AudioStreamPlayer = $EmergingSound
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
const GOBLIN_BOSS = preload("uid://drrllpdvbctga")
@export var reveal_delay := 0.0
var parent: CharacterBody2D

func _ready() -> void:
	self.tree_sprite.material.set_shader_parameter("dissolve_value", 0.0)
	self.tree_sprite.visible = false
	tree_sprite.scale = Vector2.ONE * randf_range(0.8, 1.2)
	if reveal_delay > 0.0:
		await get_tree().create_timer(reveal_delay).timeout

	reveal()
	
func reveal() -> void:
	self.tree_sprite.visible = true
	self.emerging_sound.pitch_scale = randf_range(0.3, 0.8)
	self.emerging_sound.volume_db = randf_range(-12.0, -6.0)
	self.emerging_sound.play()
	var tween = get_tree().create_tween()
	tween.tween_property(
		self.tree_sprite.material,
		"shader_parameter/dissolve_value",
		1.0,
		0.1
		).from(0.0)

func _process(_delta: float) -> void:
	if !parent:
		kill_myself()

func kill_myself():
	collision_shape_2d.set_deferred("disabled", true)
	var tween = get_tree().create_tween()
	tween.tween_property(
		self.tree_sprite.material,
		"shader_parameter/dissolve_value",
		0.0,
		1
		).from(1.0)
	tween.tween_callback(self.queue_free)
	
