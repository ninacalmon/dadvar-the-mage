extends Control

@onready var death_title: RichTextLabel = $DeathTitle
@onready var death_desc: RichTextLabel = $DeathDesc
@onready var score_label: RichTextLabel = $"../../ScoreLabel"

func _ready() -> void:
	death_desc.text = "press 'R' to restart."
