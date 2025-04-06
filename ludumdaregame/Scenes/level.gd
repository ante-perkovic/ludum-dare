extends Node2D

var tile_selector = preload("res://scripts/tile_texture_selector.gd")

var on_next_level_callback: Callable
var on_previous_level_callback: Callable

func create_level():
	var level_generator = get_node("LevelGenerator")
	var level_tiles = level_generator.generate_level_tiles()

	var tileMapLayer: TileMapLayer = get_node("TileMapLayer")

	for y in range(len(level_tiles)):
		for x in range(len(level_tiles[y])):
			#var tile = level_tiles[y][x]
			var coords = tile_selector.get_tile_atlas_coords(level_tiles, x, y)
			if coords != null:
				tileMapLayer.set_cell(Vector2i(x, y), 0, coords)

func go_to_next_level():
	if on_next_level_callback:
		on_next_level_callback.call()

func return_to_previous_level():
	if on_previous_level_callback:
		on_previous_level_callback.call()

func _ready() -> void:
	pass
