extends Node

const ROOM_FILE_BIG = "./Assets/Rooms/big_rooms.txt"
const ROOM_FILE_SMALL = "./Assets/Rooms/small_rooms.txt"

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

	if room_type == utils.RoomType.BIG:
		var room_string = BIG_ROOMS[rng.randi_range(0, BIG_ROOMS.size() - 1)]
		tiles = utils.parse_room(room_string)
	elif room_type == utils.RoomType.SMALL:
		var room_string = SMALL_ROOMS[rng.randi_range(0, SMALL_ROOMS.size() - 1)]
		tiles = utils.parse_room(room_string)

	if rng.randi() % 2 == 0:
		tiles = utils.flip_tiles(tiles)

	return tiles

func generate_level_tiles():
	load_rooms()
	var rng = RandomNumberGenerator.new()

	var room = create_room_tiles(utils.RoomType.BIG)
	room = utils.add_margin(room)
	
	var number_of_rooms = rng.randi_range(3, 6)

	for i in range(number_of_rooms):
		rng.randomize()
		var roll = rng.randi_range(0, 99)
		var room_type = utils.RoomType.BIG if roll < 25 else utils.RoomType.SMALL
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
