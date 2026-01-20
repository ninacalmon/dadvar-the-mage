extends CenterContainer

@onready var book_animation: AnimatedSprite2D = %BookAnimation
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

var possible_spell_options: Array[EventSpell] = [SoulPiercer.new(), VampiricGoblet.new()]
var spell_left: EventSpell
var spell_right: EventSpell


var is_animation_backwards = false

func _ready():
	EventBus.player_level_up.connect(_on_player_level_up)
	choice_l.pressed.connect(_on_choice_l_pressed)
	choice_r.pressed.connect(_on_choice_r_pressed)
	self.hide()
	
	stream_player = AudioStreamPlayer.new()
	stream_player.pitch_scale = 0.5
	stream_player.stream = opening_book_sound
	book_animation.add_child(stream_player)
	
	stream_player2 = AudioStreamPlayer.new()
	stream_player.stream = closing_book_sound
	book_animation.add_child(stream_player2)

func _on_choice_l_pressed() -> void:
	if self.spell_left != null:
		EventBus.new_spell_added.emit(self.spell_left)
	## APPEND OPTION NOT CHOSEN TO POSSIBLE SPELL OPTIONS ARRAY AGAIN
	on_selected_choice(self.spell_right)


func _on_choice_r_pressed() -> void:
	if self.spell_right != null:
		EventBus.new_spell_added.emit(self.spell_right)
	## APPEND OPTION NOT CHOSEN TO POSSIBLE SPELL OPTIONS ARRAY AGAIN
	on_selected_choice(self.spell_left)

func _on_player_level_up(_level: int):
	is_animation_backwards = false
	get_tree().paused = true

	if possible_spell_options.size() != 0:
		var random_num_array_bound_left = randi() % possible_spell_options.size()
		spell_left = possible_spell_options.get(random_num_array_bound_left)
		possible_spell_options.remove_at(random_num_array_bound_left)
		sprite_l.texture = spell_left.get_event_spell_sprite_texture()
		desc_l.text = spell_left.get_event_spell_description()
		title_l.text = spell_left.get_event_spell_title()
		choice_l.show()
	else:
		spell_left = null
		## NEED TO DO SOMETHING WHEN THERE ARE NO OPTIONS LEFT
		#choice_l.hide()

	if possible_spell_options.size() != 0:
		var random_num_array_bound_right = randi() % possible_spell_options.size()
		spell_right = possible_spell_options.get(random_num_array_bound_right)
		possible_spell_options.remove_at(random_num_array_bound_right)
		sprite_r.texture = spell_right.get_event_spell_sprite_texture()
		desc_r.text = spell_right.get_event_spell_description()
		title_r.text = spell_right.get_event_spell_title()
		choice_r.show()
	else:
		spell_right = null
		## NEED TO DO SOMETHING WHEN THERE ARE NO OPTIONS LEFT
		#choice_r.hide()

	## REALLY IMPORTANT!!!!!!!!!!!!!!!!!!!! OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
	## DO SOMETHING WHEN THERE ARE NOT TWO OPTIONS OF SPELLS TO CHOOSE
	## TELL PLAYER OR SOMETHING
	book_animation.play()
	#stream_player.play()
	book_animation.animation_finished.connect(_on_book_animation_finished)

func _on_book_animation_finished():
	if !is_animation_backwards:
		self.visible = !self.visible
	else:
		get_tree().paused = false

func on_selected_choice(spell_not_chosen: EventSpell):
	if spell_not_chosen != null:
		possible_spell_options.append(spell_not_chosen)
	self.hide() 
	book_animation.play_backwards()
	#stream_player2.play()
	is_animation_backwards = true
