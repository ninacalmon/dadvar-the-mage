extends StaticBody2D

@onready var door_area: Area2D = $DoorArea
@onready var sprite_house: AnimatedSprite2D = $SpriteHouse

func _ready() -> void:
	door_area.area_entered.connect(open_the_door)

func open_the_door(_area: Area2D):
	sprite_house.play("opening")
