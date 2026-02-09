extends StaticBody2D
class_name House

@onready var inside_house_area: Area2D = $InsideHouseArea
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var door_text_label_timer: Timer = %DoorTextLabelTimer
@onready var door_text_label: RichTextLabel = %DoorTextLabel
@onready var door_area: Area2D = $DoorArea
@onready var animated_sprite_house: AnimatedSprite2D = $SpriteHouse
@onready var door_opening_audio: AudioStreamPlayer = $DoorOpeningAudio

var lamps_lighted: int = 0
var is_colliding: bool = false
var is_door_open: bool = false

func _ready() -> void:
	animated_sprite_house.play("closed")
	door_area.area_entered.connect(_on_area_entered)
	door_area.area_exited.connect(_on_area_exited)
	inside_house_area.area_entered.connect(end_game)

	door_text_label_timer.timeout.connect(func(): door_text_label.hide())

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Interact") && is_colliding:
		if lamps_lighted < 2:
			door_text_label_timer.stop()
			door_text_label.text = "it's too dark to open the door."
			door_text_label.show()
			door_text_label_timer.start()
		elif lamps_lighted >= 2 and is_door_open == false:
			is_door_open = true
			door_opening_audio.play()
			await get_tree().create_timer(2.5).timeout
			animated_sprite_house.play("opening")
			await get_tree().create_timer(1).timeout
			animated_sprite_house.play("open")
			collision_shape_2d.one_way_collision = true

func _on_area_entered(area: Area2D):
	if area is PlayerCutscene and is_door_open == false:
		is_colliding = true

		door_text_label_timer.stop()

		door_text_label.text = "Press 'E' to interact."
		door_text_label.show()

		door_text_label_timer.start()

func _on_area_exited(area: Area2D):
	if area is PlayerCutscene:
		is_colliding = false

func end_game(area: Area2D):
	if area is PlayerCutscene:
		var player: PlayerCutscene = area

		var tween = get_tree().create_tween()
		tween.tween_property(player.player_sprite, "modulate:a", 0, 0.8)
		tween.set_parallel().tween_property(player.stats_module, "current_move_speed", 0, 0.6)
		await tween.finished
		LevelTransition.change_scene_to("res://UI/Menu/main_menu.tscn", 2, 1)
