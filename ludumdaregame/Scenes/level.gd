extends Node2D

var tile_selector = preload("res://scripts/tile_texture_selector.gd")
var utils = preload("res://scripts/generate_utils.gd")

var theme_list = [ "forest", "inferno", "disco"]

var allowed_names = null
var theme_id = null

func create_level(current_depth, allowed_depth):
	# Current depth will determine how hard is the level, allowed depth is used
	# for side quest NPC, use -1 if the main level
	var level_generator = get_node("LevelGenerator")
	var player = get_node("Player")
	var backgroundLayer: TileMapLayer = get_node("BackgroundLayer")
	var foregroundLayer: TileMapLayer = get_node("ForegroundLayer")
	var npc_scene = preload("res://Characters/npc.tscn")
	var enemy_scene = preload("res://Characters/enemy.tscn")
	var coin_scene = preload("res://Collectibles/Coin/coin.tscn")
	var heart_scene = preload("res://Collectibles/Heart/Heart.tscn")
	var weapon_scenes = [
		preload("res://Weapons/Gun.tscn"),
		preload("res://Weapons/AssaultRifle.tscn"),
		preload("res://Weapons/Shotgun.tscn"),
	]
	var background_margin = 100

	var floor_tiles: Array[Vector2i] = []
	var level_tiles = level_generator.generate_level_tiles()

	var width = len(level_tiles[0])
	var height = len(level_tiles)
	
	var COIN_FREQUENCY = 10 # smaller == more rare

	var number_of_enemies = current_depth + randi_range(3, 10)
	var number_of_normal_npc = 0

	theme_id = randi() % theme_list.size()
	set_random_name_list()

	# Draw foreground
	var tile_set_id = 0
	for y in range(-background_margin, height + background_margin):
		for x in range(-background_margin, width + background_margin):
			var coords = Vector2i(x, y)
			var tile_coords = tile_selector.get_tile_texture_coords(level_tiles, x, y)
			if tile_coords != null:
				backgroundLayer.set_cell(coords, tile_set_id, tile_coords)
			# Used for spawning objects later
			if utils.get_tile_type(level_tiles, x, y) == utils.TileType.FLOOR:
				floor_tiles.append(coords)
				if randf() < 0.05:
					foregroundLayer.set_cell(coords, tile_set_id, tile_selector.get_random_decoration_inside())
			elif utils.get_tile_type(level_tiles, x, y) == utils.TileType.OUTSIDE:
				if randf() < 0.02:
					foregroundLayer.set_cell(coords, tile_set_id, tile_selector.get_random_decoration_outside())
	floor_tiles.shuffle()
	
	# Teleport player to some position
	if player and floor_tiles.size() > 0:
		player.global_position = backgroundLayer.map_to_local(get_random_floor_tile(floor_tiles))

	# Spawn NPCS
	if allowed_depth == -1:
		# Spawn one level that is main_quest
		var number_of_dreaming_npc = 10 + randi_range(2,3)
		spawn_npcs(npc_scene, floor_tiles, backgroundLayer, 1, true, current_depth+1, -1)
		spawn_npcs(npc_scene, floor_tiles, backgroundLayer, number_of_dreaming_npc, true, current_depth+1, 1)
	elif allowed_depth == 1:
		var number_of_dreaming_npc = randi_range(2,3)
		spawn_npcs(npc_scene, floor_tiles, backgroundLayer, number_of_dreaming_npc, true, current_depth+1, allowed_depth - 1)
	spawn_npcs(npc_scene, floor_tiles, backgroundLayer, number_of_normal_npc, false, 0, 0)

	# Spawn enemies
	spawn_enemies(enemy_scene, floor_tiles, backgroundLayer, player.global_position, randi() % 6 + 3, 4)
	
	# Spawn weapons
	spawn_weapons(weapon_scenes.pick_random(), floor_tiles, backgroundLayer, player.global_position, 2, 4)
	
	# Spawn coins
	spawn_coins(coin_scene, floor_tiles, backgroundLayer, player.global_position, 20, 3)
	
	# spawn hears
	spawn_hearts(heart_scene, floor_tiles, backgroundLayer, player.global_position, 4, 3)

func set_random_name_list() -> void:
	var name_lists = [
		["Luna", "Nova", "Zephyr", "Orion", "Vega", "Lyra", "Sirius", "Andromeda", "Altair", "Cassiopeia"],
		["Moss", "Thorn", "Willow", "Briar", "Fern", "Clover", "Ivy", "Rowan", "Birch", "Sage"],
		["Borna", "Anica", "Mirko", "Jasna", "Bojan", "Vesna", "Dragan", "Lidija", "Goran", "Tatjana"],
		["Jake", "Emily", "Connor", "Madison", "Tyler", "Ashley", "Brandon", "Brittany", "Logan", "Hailey"]
	]
	if theme_list[theme_id] == "inferno":
		allowed_names = ["Ash", "Blaze", "Ember", "Flint", "Coal", "Inferno", "Kindle", "Pyra", "Scorch", "Cinder"]
		return
	var selected = name_lists[randi() % name_lists.size()]
	selected.shuffle()
	allowed_names = selected
	

func get_random_floor_tile(floor_tiles: Array[Vector2i]) -> Vector2i:
	return floor_tiles.pop_back()

func spawn_npcs(npc_scene, floor_tiles, tile_map, count: int, is_dreaming:bool, current_depth: int, allowed_depth: int) -> void:
	for i in count:
		if floor_tiles.is_empty(): break
		var npc = npc_scene.instantiate()
		npc.current_depth = current_depth
		var npc_name = allowed_names[randi() % allowed_names.size()]
		npc.set_npc_name(npc_name)	
		npc.allowed_depth = randi_range(0, allowed_depth)
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

func spawn_weapons(weapon_scene, floor_tiles, tile_map, player_pos, count, min_distance):
	for i in count:
		if floor_tiles.is_empty(): break
		var weapon = weapon_scene.instantiate()
		var pos: Vector2i

		while true:
			if floor_tiles.is_empty(): break
			pos = get_random_floor_tile(floor_tiles)
			var dist = player_pos.distance_to(tile_map.map_to_local(pos)) / tile_map.tile_set.tile_size.x
			if dist > min_distance:
				break
		weapon.global_position = tile_map.map_to_local(pos)
		add_child(weapon)

func spawn_hearts(heart_scene, floor_tiles, tile_map, player_pos, count, min_distance):
	for i in count:
		if floor_tiles.is_empty(): break
		var health = heart_scene.instantiate()
		var pos: Vector2i

		while true:
			if floor_tiles.is_empty(): break
			pos = get_random_floor_tile(floor_tiles)
			var dist = player_pos.distance_to(tile_map.map_to_local(pos)) / tile_map.tile_set.tile_size.x
			if dist > min_distance:
				break
		health.global_position = tile_map.map_to_local(pos)
		add_child(health)
