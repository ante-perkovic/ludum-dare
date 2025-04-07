extends Node2D

var tile_selector = preload("res://scripts/tile_texture_selector.gd")
var utils = preload("res://scripts/generate_utils.gd")

var allowed_names = null
var level_theme = null

func create_level(current_depth=0, allowed_depth=-1):
	# Current depth will determine how hard is the level, allowed depth is used
	# for side quest NPC, use -1 if the main level
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

	var number_of_enemies = current_depth + randi_range(3, 10)
	var number_of_normal_npc = 0

	set_random_theme()
	set_random_name_list()


	# Draw foreground
	for y in range(-background_margin, height + background_margin):
		for x in range(-background_margin, width + background_margin):
			var coords = tile_selector.get_tile_texture_coords(level_tiles, x, y)
			if coords != null:
				tileMapLayer.set_cell(Vector2i(x, y), 0, coords)
			# Used for spawning objects later
			if utils.get_tile_type(level_tiles, x, y) == utils.TileType.FLOOR:
				floor_tiles.append(Vector2i(x, y))
	floor_tiles.shuffle()
	
	# Teleport player to some position
	if player and floor_tiles.size() > 0:
		player.global_position = tileMapLayer.map_to_local(get_random_floor_tile(floor_tiles))

	# Spawn NPCS
	if allowed_depth == -1:
		# Spawn one level that is main_quest
		var number_of_dreaming_npc = 10+randi_range(2,3)
		spawn_npcs(npc_scene, floor_tiles, tileMapLayer, 1, current_depth+1, -1)
		spawn_npcs(npc_scene, floor_tiles, tileMapLayer, number_of_dreaming_npc, current_depth+1, 2)
	elif allowed_depth == 1 or allowed_depth == 2:
		var number_of_dreaming_npc = randi_range(2,3)
		spawn_npcs(npc_scene, floor_tiles, tileMapLayer, number_of_dreaming_npc, current_depth+1, allowed_depth - 1)
	spawn_npcs(npc_scene, floor_tiles, tileMapLayer, number_of_normal_npc, 0, 0)

	# Spawn enemies
	spawn_enemies(enemy_scene, floor_tiles, tileMapLayer, player.global_position, randi() % 6 + 3, 4)
	
	spawn_coins(coin_scene, floor_tiles, tileMapLayer, player.global_position, 20, 3)

func set_random_name_list() -> void:
	var name_lists = [
		["Luna", "Nova", "Zephyr", "Orion", "Vega", "Lyra", "Sirius", "Andromeda", "Altair", "Cassiopeia"],
		["Moss", "Thorn", "Willow", "Briar", "Fern", "Clover", "Ivy", "Rowan", "Birch", "Sage"],
		["Borna", "Anica", "Mirko", "Jasna", "Bojan", "Vesna", "Dragan", "Lidija", "Goran", "Tatjana"],
		["Jake", "Emily", "Connor", "Madison", "Tyler", "Ashley", "Brandon", "Brittany", "Logan", "Hailey"]
	]
	if level_theme == "inferno":
		allowed_names = ["Ash", "Blaze", "Ember", "Flint", "Coal", "Inferno", "Kindle", "Pyra", "Scorch", "Cinder"]
		return
	var selected = name_lists[randi() % name_lists.size()]
	selected.shuffle()
	allowed_names = selected

func set_random_theme() -> void:
	var theme_list = ["inferno", "forest", "disco"]
	level_theme = theme_list[randi() % theme_list.size()]

func get_random_floor_tile(floor_tiles: Array[Vector2i]) -> Vector2i:
	return floor_tiles.pop_back()

func spawn_npcs(npc_scene, floor_tiles, tile_map, count: int, current_depth: int, allowed_depth: int) -> void:
	for i in count:
		if floor_tiles.is_empty(): break
		var npc = npc_scene.instantiate()
		npc.current_depth = current_depth
		var npc_name = allowed_names[randi() % allowed_names.size()]
		npc.set_npc_name(npc_name)
		if allowed_depth == -1 or allowed_depth == 0:
			npc.allowed_depth = allowed_depth
		else:
			npc.allowed_depth = randi_range(1, allowed_depth)
		npc.is_dreaming = npc.allowed_depth != 0
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

func spawn_coins(coin_scene, floor_tiles, tile_map, player_pos, count, min_distance):
	for i in count:
		if floor_tiles.is_empty(): break
		var coin = coin_scene.instantiate()
		var pos: Vector2i

		while true:
			if floor_tiles.is_empty(): break
			pos = get_random_floor_tile(floor_tiles)
			var dist = player_pos.distance_to(tile_map.map_to_local(pos)) / tile_map.tile_set.tile_size.x
			if dist > min_distance:
				break
		coin.global_position = tile_map.map_to_local(pos)
		add_child(coin)
