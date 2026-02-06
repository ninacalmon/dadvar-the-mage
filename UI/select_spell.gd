extends CenterContainer

@onready var book_animation: AnimatedSprite2D = %BookAnimation
var current_animation_frame = 0
var opening_book_sound = preload("res://Sounds/book-turn-page-2-92381.mp3")
var closing_book_sound = preload("res://Sounds/book-closing-466850.mp3")
var stream_player
var stream_player2

@onready var control: Control = $Control
@onready var choice_l: Button = %ChoiceL
@onready var choice_r: Button = %ChoiceR
@onready var sprite_l: Sprite2D = %SpriteL
@onready var sprite_r: Sprite2D = %SpriteR
@onready var desc_l: RichTextLabel = %"Desc L"
@onready var desc_r: RichTextLabel = %"Desc R"
@onready var title_l: RichTextLabel = %"Title L"
@onready var title_r: RichTextLabel = %"Title R"
@onready var level_l: RichTextLabel = %"Level L"
@onready var level_r: RichTextLabel = %"Level R"
@onready var hover_l: TextureButton = %"Hover L"
@onready var hover_r: TextureButton = %"Hover R"
@onready var l_max_details_text: RichTextLabel = $"Control/Hover L/LMaxDetailsText"
@onready var r_max_details_text: RichTextLabel = $"Control/Hover R/RMaxDetailsText"


## Level_l and level_r have the same placeholder text
@onready var level_string_template: String = level_l.text

@onready var player: Player = get_tree().get_first_node_in_group("PlayerGroup")

var possible_spell_options: Array[EventSpell] = [
	SoulPiercer.new(),
	VampiricGoblet.new(),
	TitansSkin.new(),
	YggdrasilTea.new(),
	BoreasSwiftness.new(),
	OgresScent.new(),
	ProfaneBolt.new()
]

var placeholder_spell = SpellWaste.new()
var spell_left: EventSpell
var spell_right: EventSpell

var is_animation_backwards = false

var cursor_texture: Texture2D

func _ready():
	EventBus.player_level_up.connect(_on_player_level_up)
	choice_l.pressed.connect(_on_choice_l_pressed)
	choice_r.pressed.connect(_on_choice_r_pressed)
	book_animation.frame_changed.connect(_on_book_animation_frame_changed)
	control.hide()
	
	stream_player = AudioStreamPlayer.new()
	stream_player.pitch_scale = 1.3
	stream_player.stream = opening_book_sound
	book_animation.add_child(stream_player)
	
	stream_player2 = AudioStreamPlayer.new()
	stream_player2.stream = closing_book_sound
	book_animation.add_child(stream_player2)

func _on_choice_l_pressed() -> void:
	if self.spell_left != null:
		var spell_next_level = self.spell_left.get_event_spell_current_level() + 1
		EventBus.new_spell_added.emit(self.spell_left, spell_next_level)

		if spell_next_level < self.spell_left.get_event_spell_max_level():
			possible_spell_options.append(self.spell_left)

	self.on_selected_choice(self.spell_right)

func _on_choice_r_pressed() -> void:
	if self.spell_right != null:
		var spell_next_level = self.spell_right.get_event_spell_current_level() + 1
		EventBus.new_spell_added.emit(self.spell_right, spell_next_level)

		if spell_next_level < self.spell_right.get_event_spell_max_level():
			possible_spell_options.append(self.spell_right)

	self.on_selected_choice(self.spell_left)

func _on_player_level_up(_level: int):
	cursor_texture = preload("res://Sprites/big_hand_cursor.png")
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(0, 0))
	is_animation_backwards = false
	get_tree().paused = true

	self.spell_left = self.select_random_spell(self.possible_spell_options, self.placeholder_spell)
	self.spell_right = self.select_random_spell(self.possible_spell_options, self.placeholder_spell)

	## SPELL LEFT
	self.show_spell_on_ui(self.spell_left, self.sprite_l, self.desc_l, self.title_l, self.choice_l, self.level_l, self.hover_l, self.l_max_details_text)
	## SPELL RIGHT
	self.show_spell_on_ui(self.spell_right, self.sprite_r, self.desc_r, self.title_r, self.choice_r, self.level_r, self.hover_r, self.r_max_details_text)

	book_animation.show()
	book_animation.play()
	stream_player.play()
	book_animation.animation_finished.connect(_on_book_animation_finished)

func _on_book_animation_finished():
	if !is_animation_backwards:
		
		control.visible = !control.visible
		current_animation_frame = 0
	else:
		cursor_texture = preload("res://Sprites/cursor_hand.png")
		Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, Vector2(0, 0))
		get_tree().paused = false
		book_animation.hide()

func _on_book_animation_frame_changed():
	current_animation_frame += 1
	## VERIFY IF THERE IS A BETTER WAY TO DEFINE WHICH FRAME THIS SOUND NEEDS TO PLAY
	## CURRENTLY IT IS HARD CODED HERE
	if current_animation_frame == 14:
		stream_player2.play()

func on_selected_choice(spell_not_chosen: EventSpell):
	if spell_not_chosen != null and spell_not_chosen != self.placeholder_spell:
		## APPEND OPTION NOT CHOSEN TO POSSIBLE SPELL OPTIONS ARRAY AGAIN
		possible_spell_options.append(spell_not_chosen)

	control.hide() 
	book_animation.play_backwards()
	is_animation_backwards = true

func select_random_spell(options: Array, fallback):
	## VERIFICAR COMO FAZER QUANDO NAO TIVER MAIS OPÇOES
	if options.is_empty():
		return fallback
	
	var index := randi() % options.size()
	var selected_spell = options.pop_at(index)

	for player_spell in player.spells:
		if player_spell == selected_spell:
			selected_spell = player_spell

	return selected_spell

func show_spell_on_ui(
	spell: EventSpell,
	sprite: Sprite2D,
	description: RichTextLabel,
	title: RichTextLabel,
	choice: Button,
	level: RichTextLabel,
	hover: TextureButton,
	max_detail: RichTextLabel
	) -> void:
	sprite.texture = spell.get_event_spell_sprite_texture()
	description.text = spell.get_event_spell_description()
	title.text = spell.get_event_spell_title()
	var current_level = spell.get_event_spell_current_level()
	var max_level = spell.get_event_spell_max_level()

	level.bbcode_text = level_string_template.format({
		"C": current_level,
		"N": current_level + 1,
		"M": max_level
	})
	if spell.get_event_spell_next_level() == spell.get_event_spell_max_level():
		max_detail.text = spell.get_event_spell_max_level_detail()
		hover.show()
	else:
		hover.hide()
	
	choice.show()
