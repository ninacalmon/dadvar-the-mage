extends Control

@onready var death_title: RichTextLabel = $DeathTitle
@onready var death_desc: RichTextLabel = $DeathDesc
@onready var score_label: RichTextLabel = $"../../ScoreLabel"

var text_option1: String = '“Omar Dadvar’s heart stopped, but the curse he carried lingered in the air.”'
var text_option2: String = '“Omar Dadvar’s final spell disperses as he meets his end.”'
var text_option3: String = '"All that power... Still not enough..."'

var text_option_arr: Array = [text_option1, text_option2, text_option3]

func _ready() -> void:
	death_desc.text = "press 'R' to restart."
