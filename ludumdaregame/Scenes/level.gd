extends Node2D

var tile_selector = preload("res://scripts/tile_texture_selector.gd")
var utils = preload("res://scripts/generate_utils.gd")

func create_level():
	var level_generator = get_node("LevelGenerator")
	var player = get_node("Player")
	var tileMapLayer: TileMapLayer = get_node("TileMapLayer")
	var npc_scene = preload("res://Characters/npc.tscn")
	var enemy_scene = preload("res://Characters/enemy.tscn")
	var coin_scene = preload("res://Collectibles/Coin/coin.tscn")
	var background_margin = 100

	var floor_tiles: Array[Vector2i] = []
	var level_tiles = level_generator.generate_level_tiles()

	var width = len(level_tiles[0])
	var height = len(level_tiles)
	
	var COIN_FREQUENCY = 10 # smaller == more rare

	# Draw foreground
	for y in range(-background_margin, height + background_margin):
		for x in range(-background_margin, width + background_margin):
			var coords = tile_selector.get_tile_texture_coords(level_tiles, x, y)
			if coords != null:
				tileMapLayer.set_cell(Vector2i(x, y), 0, coords)

			if utils.get_tile_type(level_tiles, x, y) == utils.TileType.FLOOR:
				floor_tiles.append(Vector2i(x, y))

	floor_tiles.shuffle()

	if player and floor_tiles.size() > 0:
		player.global_position = tileMapLayer.map_to_local(get_random_floor_tile(floor_tiles))

	spawn_npcs(npc_scene, floor_tiles, tileMapLayer, true, randi() % 10 + 1)
	spawn_npcs(npc_scene, floor_tiles, tileMapLayer, false, 0) # randi() % 4 + 1 if you want awake ones

	spawn_enemies(enemy_scene, floor_tiles, tileMapLayer, player.global_position, randi() % 6 + 3, 4)
	
	spawn_coins(coin_scene, floor_tiles, tileMapLayer, 10)

func get_random_floor_tile(floor_tiles: Array[Vector2i]) -> Vector2i:
	return floor_tiles.pop_back()

func spawn_npcs(npc_scene, floor_tiles, tile_map, is_dreaming: bool, count: int) -> void:
	for i in count:
		if floor_tiles.is_empty(): break
		var npc = npc_scene.instantiate()
		npc.is_dreaming = is_dreaming
		npc.global_position = tile_map.map_to_local(get_random_floor_tile(floor_tiles))
		add_child(npc)

func spawn_enemies(enemy_scene, floor_tiles, tile_map, player_pos: Vector2, count: int, min_distance: float) -> void:
	for i in count:
		if floor_tiles.is_empty(): break
		var enemy = enemy_scene.instantiate()
		var pos: Vector2i

		while true:
			if floor_tiles.is_empty(): break
			pos = get_random_floor_tile(floor_tiles)
			var dist = player_pos.distance_to(tile_map.map_to_local(pos)) / tile_map.tile_set.tile_size.x
			if dist > min_distance:
				break
		enemy.global_position = tile_map.map_to_local(pos)
		add_child(enemy)

func spawn_coins(coin_scene, floor_tiles, tile_map, count):
	for i in count:
		if floor_tiles.is_empty():
			break
		var coin = coin_scene.instantiate()
		var pos: Vector2i
		
		while true:
			# TODO: validate
			if floor_tiles.is_empty(): 
				break
			pos = get_random_floor_tile(floor_tiles)

		coin.global_position = tile_map.map_to_local(pos)
		add_child(coin)
