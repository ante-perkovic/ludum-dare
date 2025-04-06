extends Node

const ROOM_FILE_BIG = "res://Assets/Rooms/big_rooms.txt"
const ROOM_FILE_SMALL = "res://Assets/Rooms/small_rooms.txt"

var BIG_ROOMS = []
var SMALL_ROOMS = []
var rooms_loaded := false

var utils = preload("./generate_utils.gd")

func get_rooms_from_text_file(file_path: String) -> Array:
	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	var rooms = []
	for block in content.strip_edges().split("\n\n"):
		rooms.append(block)
	return rooms

func load_rooms():
	if not rooms_loaded:
		BIG_ROOMS = get_rooms_from_text_file(ROOM_FILE_BIG)
		SMALL_ROOMS = get_rooms_from_text_file(ROOM_FILE_SMALL)
		rooms_loaded = true

func create_room_tiles(room_type: int) -> Array:
	load_rooms()  # ensure loaded before use

	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var tiles = []

	if room_type == utils.RoomType.TOILET:
		var toilet_width = rng.randi_range(1, 3)
		var toilet_height = rng.randi_range(1, 2)
		var toilets = rng.randi_range(3, 6)
		var width = toilet_width + 1 + rng.randi_range(2, 4)
		var height = (toilet_height + 1) * toilets - 1

		tiles.resize(height)
		for y in range(height):
			tiles[y] = []
			for x in range(width):
				tiles[y].append(utils.Tile.new(utils.TileType.FLOOR))

		utils.put_tile(tiles, toilet_width + 2, 0, utils.Tile.new(utils.TileType.FLOOR, true))
		utils.put_tile(tiles, toilet_width + 2, height - 1, utils.Tile.new(utils.TileType.FLOOR, true))
		utils.put_tile(tiles, width - 1, height / 3, utils.Tile.new(utils.TileType.FLOOR, true))
		utils.put_tile(tiles, width - 1, 2 * height / 3, utils.Tile.new(utils.TileType.FLOOR, true))

		for i in range(toilets):
			if i != 0:
				utils.put_tiles(
					tiles,
					Vector2(0, (toilet_height + 1) * i - 1),
					Vector2(toilet_width, (toilet_height + 1) * i - 1),
					utils.TileType.WALL
				)
			utils.put_tiles(
				tiles,
				Vector2(toilet_width, (toilet_height + 1) * i),
				Vector2(toilet_width, (toilet_height + 1) * (i + 1) - 3),
				utils.TileType.WALL
			)
	elif room_type == utils.RoomType.BIG:
		var room_string = BIG_ROOMS[rng.randi_range(0, BIG_ROOMS.size() - 1)]
		tiles = utils.parse_room(room_string)
	elif room_type == utils.RoomType.SMALL:
		var room_string = SMALL_ROOMS[rng.randi_range(0, SMALL_ROOMS.size() - 1)]
		tiles = utils.parse_room(room_string)

	if rng.randi() % 2 == 0:
		tiles = utils.flip_tiles(tiles)

	return tiles

func generate_level():
	load_rooms()

	var room = create_room_tiles(utils.RoomType.BIG)
	room = utils.add_margin(room)

	for i in range(5):
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var roll = rng.randi_range(0, 99)
		var room_type = utils.RoomType.BIG if roll < 40 else utils.RoomType.SMALL if roll < 70 else utils.RoomType.TOILET

		var new_room = create_room_tiles(room_type)
		new_room = utils.add_margin(new_room)
		var combined = null
		combined = utils.combine_rooms(room, new_room)

		if combined:
			room = combined
			room = utils.add_margin(room)
	utils.surround_with_walls(room)
	#utils.draw_tiles(room)
	return room
