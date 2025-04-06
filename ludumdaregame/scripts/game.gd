extends Node2D

var generate_level = preload("./generate_level.gd")
var utils = preload("./generate_utils.gd")
var tile_selector = preload("./tile_texture_selector.gd")

func _ready() -> void:
	var level_gen = get_node("LevelGenerator")
	var level = level_gen.generate_level()

	var tileMapLayer: TileMapLayer = get_node("TileMapLayer")

	for y in range(len(level)):
		for x in range(len(level[y])):
			var tile = level[y][x]
			var coords = tile_selector.get_tile_atlas_coords(level, x, y)
			if coords != null:
				tileMapLayer.set_cell(Vector2i(x, y), 0, coords)
