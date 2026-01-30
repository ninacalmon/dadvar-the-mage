extends Node2D

@export var noise_woods_texture: NoiseTexture2D
var noise: Noise

var width: float = 500
var height: float = 500
var noise_value_arr = []

@onready var tile_map_layer_lighted: TileMapLayer = %TileMapLayer_Lighted
@onready var tile_map_layer_occluded: TileMapLayer = %TileMapLayer_Occluded

var source_id = 1
var woods_atlas = [Vector2i(1, 2), Vector2i(3, 2), Vector2i(5, 4), Vector2i(6, 2), Vector2i(10, 2), Vector2i(14, 2), Vector2i(16, 2), Vector2i(21, 2)]
var ground_atlas = [Vector2i(2,0), Vector2i(3, 0), Vector2i(4, 0), Vector2i(5, 0), Vector2i(6,0), Vector2i(7, 0), Vector2i(8, 0), Vector2i(9, 0), Vector2i(10, 0), Vector2i(11, 0)]

var approved_seeds = [3019866663, 4037956941, 2924637956]

func new_seed():
	#randomize()
	var random_seed = approved_seeds.pick_random()
	seed(random_seed)
	return random_seed

func _ready() -> void:
	print(new_seed())
	noise = noise_woods_texture.noise
	generate_world()
	
func generate_world():
	for x in range(-width/2, width/2):
		for y in range(-height/2, height/2):
			if x % 2 == 0 and y % 2 == 0:
				var noise_value: float = noise.get_noise_2d(x, y)
				noise_value_arr.append(noise_value)
				#print("max ", noise_value_arr.max())
				#print("min ", noise_value_arr.min())
				if noise_value <= -0.55:
					# place woods
					tile_map_layer_lighted.set_cell(Vector2(x, y), source_id, woods_atlas.pick_random())
					
				elif noise_value > -0.55 and noise_value < -0.45:
					# place grass / rocks
					tile_map_layer_occluded.set_cell(Vector2(x, y), source_id, ground_atlas.pick_random())
					
				elif noise_value > -0.45:
					pass
					# place nothing
					#tile_map_layer_lighted.set_cell(Vector2(x, y), source_id, blank_atlas)
