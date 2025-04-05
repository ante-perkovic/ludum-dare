extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var map = """
	######..................................
	#    #.........#######################..
	#    ########..#    #     ##    ##   #..
	#    ##     ####    #     ##    ##   #..
	#                         ##    ##   #..
	#    ##     # ##    #     ##    ##   #..
	#    ##     # ##############         #..
	#    ##     # #............#   # #   #..
	############# ##############   # #####..
	............#                  # #......
	.#######....# ##############   # #......
	.#     #...## ####.#     #.#   # #......
	.#     #####     ###     #.##### #......
	.#                       ####### ######.
	.#     #####     ###     ##    # ##   #.
	.#     #...#######.########           #.
	.#     #..................#     ###   #.
	.#######..................#     #.#   #.
	..........................#     #.#   #.
	..........................#######.#####.
	"""

	var tileMapLayer: TileMapLayer = get_node("TileMapLayer")
	
	var lines_to_draw = map.split('\n')
	
	for i in range(len(lines_to_draw)):
		for j in range(len(lines_to_draw[i])):
			var c = lines_to_draw[i].split('')[j]
			
			if c == '#':
				tileMapLayer.set_cell(Vector2i(j, i), 0, Vector2i(9, 1))
			if c == '.':
				tileMapLayer.set_cell(Vector2i(j, i), 0, Vector2i(6, 1))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
