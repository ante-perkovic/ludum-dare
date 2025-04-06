extends Node

enum TileType { OUTSIDE, WALL, FLOOR }
enum RoomType { BIG, SMALL }
enum Orientation { TOP, LEFT, DOWN, RIGHT }

class Tile:
	var type : int
	var is_end : bool = false

	func _init(_type: int, _is_end := false):
		type = _type
		is_end = _is_end

class NotCombineableException:
	pass

static func get_tile_type(tiles: Array, x: int, y: int) -> int:
	if x < 0 or x >= tiles[0].size() or y < 0 or y >= tiles.size():
		return TileType.OUTSIDE
	return tiles[y][x].type

static func put_tile(tiles, x, y, tile: Tile):
	tiles[y][x] = tile

static func put_tiles(tiles, start: Vector2, end: Vector2, tile_type: int):
	for x in range(start.x, end.x + 1):
		for y in range(start.y, end.y + 1):
			put_tile(tiles, x, y, Tile.new(tile_type))

static func flip_tiles(tiles):
	var new_tiles = []
	for row in tiles:
		var row_2 = row.duplicate(true)
		row_2.reverse()
		new_tiles.append(row_2)
	return new_tiles

static func rotate_tiles(tiles: Array):
	var rotated := []
	var cols = tiles[0].size()
	var rows = tiles.size()
	
	for x in range(cols):
		var new_row := []
		for y in range(rows - 1, -1, -1):
			new_row.append(tiles[y][x])
		rotated.append(new_row)
	return rotated


static func find_end_tiles(tiles):
	var end_tiles = []
	for y in range(tiles.size()):
		for x in range(tiles[y].size()):
			if tiles[y][x].is_end:
				end_tiles.append(Vector2(x, y))
	return end_tiles

static func get_end_orientation(tiles, x, y):
	# Returns -1 if orientation cannot be found
	if x < tiles[0].size() - 1 and tiles[y][x + 1].type == TileType.OUTSIDE:
		return Orientation.RIGHT
	if x > 0 and tiles[y][x - 1].type == TileType.OUTSIDE:
		return Orientation.LEFT
	if y < tiles.size() - 1 and tiles[y + 1][x].type == TileType.OUTSIDE:
		return Orientation.TOP
	if y > 0 and tiles[y - 1][x].type == TileType.OUTSIDE:
		return Orientation.DOWN
	return -1

static func parse_room(text: String):
	var tiles = []
	for line in text.split("\n"):
		if line.strip_edges() == "":
			continue
		var row = []
		for c in line:
			match c:
				"E":
					row.append(Tile.new(TileType.FLOOR, true))
				"#":
					row.append(Tile.new(TileType.WALL))
				".":
					row.append(Tile.new(TileType.FLOOR))
				"x":
					row.append(Tile.new(TileType.OUTSIDE))
		if tiles.size() > 0 and row.size() != tiles[0].size():
			push_error("Row length mismatch")
		tiles.append(row)
	return tiles

static func add_margin(tiles, left := true, right := true, top := true, down := true):
	if left:
		for i in range(tiles.size()):
			tiles[i].insert(0, Tile.new(TileType.OUTSIDE))
	if right:
		for i in range(tiles.size()):
			tiles[i].append(Tile.new(TileType.OUTSIDE))
	if top:
		var row = []
		for i in range(tiles[0].size()):
			row.append(Tile.new(TileType.OUTSIDE))
		tiles.insert(0, row)
	if down:
		var row = []
		for i in range(tiles[0].size()):
			row.append(Tile.new(TileType.OUTSIDE))
		tiles.append(row)
	return tiles

static func surround_with_walls(tiles):
	var height = tiles.size()
	var width = tiles[0].size()
	for y in range(height):
		for x in range(width):
			if tiles[y][x].type == TileType.OUTSIDE:
				for dy in [-1, 0, 1]:
					for dx in [-1, 0, 1]:
						var ny = y + dy
						var nx = x + dx
						if get_tile_type(tiles, nx, ny) == TileType.FLOOR:
							tiles[y][x] = Tile.new(TileType.WALL)
				if get_tile_type(tiles, x-1, y) == TileType.FLOOR and get_tile_type(tiles, x+1, y) == TileType.FLOOR:
					tiles[y][x] = Tile.new(TileType.FLOOR)
				if get_tile_type(tiles, x, y-1) == TileType.FLOOR and get_tile_type(tiles, x, y+1) == TileType.FLOOR:
					tiles[y][x] = Tile.new(TileType.FLOOR)

static func get_dict_from_tiles(tiles, offset := Vector2(0, 0)):
	var new_dict = {}
	for y in range(tiles.size()):
		for x in range(tiles[y].size()):
			if tiles[y][x].type != TileType.OUTSIDE:
				new_dict[Vector2(x, y) + offset] = tiles[y][x]
	return new_dict

static func get_tiles_from_dict(dict):
	var keys = dict.keys()
	var min_x = keys[0].x
	var min_y = keys[0].y
	var max_x = min_x
	var max_y = min_y
	for pos in keys:
		min_x = min(min_x, pos.x)
		min_y = min(min_y, pos.y)
		max_x = max(max_x, pos.x)
		max_y = max(max_y, pos.y)
	var width = int(max_x - min_x + 1)
	var height = int(max_y - min_y + 1)
	var tiles = []
	for y in range(height):
		tiles.append([])
		for x in range(width):
			tiles[y].append(Tile.new(TileType.OUTSIDE))
	for pos in keys:
		var tile = dict[pos]
		tiles[int(pos.y - min_y)][int(pos.x - min_x)] = tile
	return tiles

static func combine_tiles_dicts(dict1, dict2):
	# Return null if not combinable
	for key in dict2.keys():
		if dict1.has(key):
			if dict1[key].type == dict2[key].type:
				continue
			return null
	var combined = dict1.duplicate()
	for key in dict2.keys():
		combined[key] = dict2[key]
	return combined

static func combine_rooms(tiles_1, tiles_2):
	# Returns null if not combineable
	var dict1 = get_dict_from_tiles(tiles_1)
	var ends = find_end_tiles(tiles_1)
	ends.shuffle()
	for end in ends:
		var orientation = get_end_orientation(tiles_1, end.x, end.y)
		if orientation == -1:
			continue
		var copy2 = []
		for row in tiles_2:
			var new_row = []
			for tile in row:
				new_row.append(tile)
			copy2.append(new_row)
		for i in range(orientation):
			copy2 = rotate_tiles(copy2)
		var starts = find_end_tiles(copy2)
		starts.shuffle()
		for start in starts:
			var start_orientation = get_end_orientation(copy2, start.x, start.y)
			if start_orientation == -1:
				continue
			if start_orientation != (orientation + 2) % 4:
				continue
			var offset = end - start
			match orientation:
				Orientation.TOP:
					offset.y += 2
					put_tile(copy2, start.x, start.y - 1, Tile.new(TileType.FLOOR))
				Orientation.DOWN:
					offset.y -= 2
					put_tile(copy2, start.x, start.y + 1, Tile.new(TileType.FLOOR))
				Orientation.LEFT:
					offset.x -= 2
					put_tile(copy2, start.x + 1, start.y, Tile.new(TileType.FLOOR))
				Orientation.RIGHT:
					offset.x += 2
					put_tile(copy2, start.x - 1, start.y, Tile.new(TileType.FLOOR))
			var dict2 = get_dict_from_tiles(copy2, offset)
			var result = combine_tiles_dicts(dict1, dict2)
			if result != null:
				return get_tiles_from_dict(result)
	return null

static func draw_tiles(tiles):
	for row in tiles:
		var line = ""
		for tile in row:
			match tile.type:
				TileType.FLOOR:
					line += "  "
				TileType.WALL:
					line += "# "
				TileType.OUTSIDE:
					line += ". "
		print(line)
	print("")
