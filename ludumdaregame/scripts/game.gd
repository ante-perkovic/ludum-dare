extends Node2D

var generate_level = preload("./generate_level.gd")
var utils = preload("./generate_utils.gd")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var level_gen = get_node("LevelGenerator")
	var level = level_gen.generate_level()

	var tileMapLayer: TileMapLayer = get_node("TileMapLayer")
	
	for i in range(len(level)):
		for j in range(len(level[i])):
			var tile = level[i][j]
			if tile.type == utils.TileType.WALL:
				tileMapLayer.set_cell(Vector2i(j, i), 0, Vector2i(9, 1))
			if tile.type == utils.TileType.FLOOR:
				tileMapLayer.set_cell(Vector2i(j, i), 0, Vector2i(6, 1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
