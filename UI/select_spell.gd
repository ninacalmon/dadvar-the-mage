extends CenterContainer

@onready var book_animation: AnimatedSprite2D = %BookAnimation
var current_animation_frame = 0
var opening_book_sound = preload("res://Sounds/book-turn-page-2-92381.mp3")
var closing_book_sound = preload("res://Sounds/book-closing-466850.mp3")
var stream_player
var stream_player2

@onready var choice_l: Button = %ChoiceL
@onready var choice_r: Button = %ChoiceR
@onready var sprite_l: Sprite2D = %SpriteL
@onready var sprite_r: Sprite2D = %SpriteR
@onready var desc_l: RichTextLabel = %"Desc L"
@onready var desc_r: RichTextLabel = %"Desc R"
@onready var title_l: RichTextLabel = %"Title L"
@onready var title_r: RichTextLabel = %"Title R"

var possible_spell_options: Array[EventSpell] = [
	SoulPiercer.new(),
	VampiricGoblet.new(),
	TitansSkin.new(),
	YggdrasilTea.new(),
	BoreasSwiftness.new()
]
var placeholder_spell = SpellWaste.new()
var spell_left: EventSpell
var spell_right: EventSpell


var is_animation_backwards = false

func _ready():
	EventBus.player_level_up.connect(_on_player_level_up)
	choice_l.pressed.connect(_on_choice_l_pressed)
	choice_r.pressed.connect(_on_choice_r_pressed)
	book_animation.frame_changed.connect(_on_book_animation_frame_changed)
	self.hide()
	
	stream_player = AudioStreamPlayer.new()
	stream_player.pitch_scale = 1.3
	stream_player.stream = opening_book_sound
	book_animation.add_child(stream_player)
	
	stream_player2 = AudioStreamPlayer.new()
	stream_player2.stream = closing_book_sound
	book_animation.add_child(stream_player2)

func _on_choice_l_pressed() -> void:
	if self.spell_left != null:
		EventBus.new_spell_added.emit(self.spell_left)

	self.on_selected_choice(self.spell_right)

func _on_choice_r_pressed() -> void:
	if self.spell_right != null:
		EventBus.new_spell_added.emit(self.spell_right)

	self.on_selected_choice(self.spell_left)

func _on_player_level_up(_level: int):
	is_animation_backwards = false
	get_tree().paused = true

	self.spell_left = self.select_random_spell(self.possible_spell_options, self.placeholder_spell)
	self.spell_right = self.select_random_spell(self.possible_spell_options, self.placeholder_spell)
	## SPELL LEFT
	self.show_spell_on_ui(self.spell_left, self.sprite_l, self.desc_l, self.title_l, self.choice_l)
	## SPELL RIGHT
	self.show_spell_on_ui(self.spell_right, self.sprite_r, self.desc_r, self.title_r, self.choice_r)

	book_animation.play()
	stream_player.play()
	book_animation.animation_finished.connect(_on_book_animation_finished)

func _on_book_animation_finished():
	if !is_animation_backwards:
		self.visible = !self.visible
		current_animation_frame = 0
	else:
		get_tree().paused = false

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

	self.hide() 
	book_animation.play_backwards()
	is_animation_backwards = true

func select_random_spell(options: Array, fallback):
	if options.is_empty():
		return fallback

	var index := randi() % options.size()
	return options.pop_at(index)

func show_spell_on_ui(
	spell: EventSpell,
	sprite: Sprite2D,
	description: RichTextLabel,
	title: RichTextLabel,
	choice: Button
	) -> void:
	sprite.texture = spell.get_event_spell_sprite_texture()
	description.text = spell.get_event_spell_description()
	title.text = spell.get_event_spell_title()
	choice.show()
