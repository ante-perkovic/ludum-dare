extends Node2D

var tile_selector = preload("res://scripts/tile_texture_selector.gd")
var utils = preload("res://scripts/generate_utils.gd")


func create_level():
	var level_generator = get_node("LevelGenerator")
	var player = get_node("Player")
	var tileMapLayer: TileMapLayer = get_node("TileMapLayer")
	var npc_scene = preload("res://Characters/npc.tscn")
	var enemy_scene = preload("res://Characters/enemy.tscn")

	var floor_tiles: Array[Vector2i] = []
	var level_tiles = level_generator.generate_level_tiles()

	for y in range(len(level_tiles)):
		for x in range(len(level_tiles[y])):
			var coords = tile_selector.get_tile_texture_coords(level_tiles, x, y)
			if coords != null:
				tileMapLayer.set_cell(Vector2i(x, y), 0, coords)

			var tile = level_tiles[y][x]
			if tile.type == utils.TileType.FLOOR:
				floor_tiles.append(Vector2i(x, y))

	# Randomize floor tile order for reuse
	floor_tiles.shuffle()

	# Move player to a random floor tile
	if player and floor_tiles.size() > 0:
		var spawn_pos = floor_tiles.pop_back()
		player.global_position = tileMapLayer.map_to_local(spawn_pos)

	# Spawn special NPCs with is_dreaming = true
	var num_dreaming = randi() % 10 + 1
	for i in num_dreaming:
		if floor_tiles.is_empty(): break
		var npc = npc_scene.instantiate()
		npc.is_dreaming = true
		var pos = floor_tiles.pop_back()
		npc.global_position = tileMapLayer.map_to_local(pos)
		add_child(npc)

	# Spawn special NPCs with is_dreaming = false
	var num_awake = 0 # randi() % 4 + 1
	for i in num_awake:
		if floor_tiles.is_empty(): break
		var npc = npc_scene.instantiate()
		npc.is_dreaming = false
		var pos = floor_tiles.pop_back()
		npc.global_position = tileMapLayer.map_to_local(pos)
		add_child(npc)

	# Spawn enemies (not too close to player)
	var num_enemies = 0 # randi() % 6 + 3
	var min_distance = 4.0  # tiles

	for i in num_enemies:
		if floor_tiles.is_empty(): break

		var enemy = enemy_scene.instantiate()
		var pos: Vector2i

		while true:
			if floor_tiles.is_empty(): break
			pos = floor_tiles.pop_back()
			var distance = player.global_position.distance_to(tileMapLayer.map_to_local(pos)) / tileMapLayer.tile_set.tile_size.x
			if distance > min_distance:
				break  # Acceptable spawn

		enemy.global_position = tileMapLayer.map_to_local(pos)
		add_child(enemy)

func _ready() -> void:
	pass
