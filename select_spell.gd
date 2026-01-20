extends HBoxContainer

@onready var canvas_layer: CanvasLayer = %CanvasLayer
@onready var animation_canvas_layer: CanvasLayer = %AnimationCanvasLayer
@onready var book_animation: AnimatedSprite2D = %BookAnimation
@onready var choice_l: Button = %ChoiceL
@onready var choice_r: Button = %ChoiceR

var possible_spell_options: Array[EventSpell] = [SoulPiercer.new(), VampiricGoblet.new()]
var spell_left: EventSpell
var spell_right: EventSpell

var is_animation_backwards = false

func _ready():
	EventBus.player_level_up.connect(_on_player_level_up)

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
		choice_l.show()
	else:
		spell_left = null
		choice_l.hide()
		

	if possible_spell_options.size() != 0:
		var random_num_array_bound_right = randi() % possible_spell_options.size()
		spell_right = possible_spell_options.get(random_num_array_bound_right)
		possible_spell_options.remove_at(random_num_array_bound_right)
		choice_r.show()
	else:
		spell_right = null
		choice_r.hide()

	## REALLY IMPORTANT!!!!!!!!!!!!!!!!!!!! OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
	## DO SOMETHING WHEN THERE ARE NOT TWO OPTIONS OF SPELLS TO CHOOSE
	## TELL PLAYER OR SOMETHING
	animation_canvas_layer.show()
	book_animation.play()
	book_animation.animation_finished.connect(_on_book_animation_finished)

func _on_book_animation_finished():
	if !is_animation_backwards:
		canvas_layer.visible = !canvas_layer.visible
	else:
		animation_canvas_layer.hide()
		get_tree().paused = false

func on_selected_choice(spell_not_chosen: EventSpell):
	possible_spell_options.append(spell_not_chosen)
	canvas_layer.hide() 
	book_animation.play_backwards()
	is_animation_backwards = true
