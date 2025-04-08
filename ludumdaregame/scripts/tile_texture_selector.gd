extends Node

class_name TileTextureSelector

const utils = preload("./generate_utils.gd")

static func get_random_texture(options: Array) -> Vector2i:
	return options[randi() % options.size()]

static func get_random_decoration_inside():
	return get_random_texture([Vector2i(2, 6), Vector2i(3, 6), Vector2i(4, 6), Vector2i(5, 6)])

static func get_random_decoration_outside():
	return get_random_texture([Vector2i(0, 6), Vector2i(1, 6)])

static func get_tile_texture_coords(tiles: Array, x: int, y: int, enclose_floors=false) -> Vector2i:
	var current = utils.get_tile_type(tiles, x, y)
	var left = utils.get_tile_type(tiles, x - 1, y)
	var right = utils.get_tile_type(tiles, x + 1, y)
	var top = utils.get_tile_type(tiles, x, y - 1)
	var bottom = utils.get_tile_type(tiles, x, y + 1)
	var top_left = utils.get_tile_type(tiles, x - 1, y - 1)
	var top_right = utils.get_tile_type(tiles, x + 1, y - 1)
	var bottom_left = utils.get_tile_type(tiles, x - 1, y + 1)
	var bottom_right = utils.get_tile_type(tiles, x + 1, y + 1)

	if current == utils.TileType.FLOOR:
		if enclose_floors:
			if top_left == utils.TileType.WALL and top_right == utils.TileType.WALL:
				top = utils.TileType.WALL
			if top_left == utils.TileType.WALL and bottom_left == utils.TileType.WALL:
				left = utils.TileType.WALL
			if bottom_right == utils.TileType.WALL and bottom_left == utils.TileType.WALL:
				bottom = utils.TileType.WALL
			if top_right == utils.TileType.WALL and bottom_right == utils.TileType.WALL:
				right = utils.TileType.WALL
		
		if left == utils.TileType.WALL and right == utils.TileType.WALL:
			return Vector2i(2, 5)  # FloorLeftRight
		elif top == utils.TileType.WALL and bottom == utils.TileType.WALL:
			return Vector2i(3, 5)  # FLoorTopBottom
		elif left == utils.TileType.WALL:
			if top == utils.TileType.WALL:
				return Vector2i(1, 1)  # FloorTopLeft
			elif bottom == utils.TileType.WALL:
				return Vector2i(1, 3)  # FloorBottomLeft
			else:
				return Vector2i(1, 2)  # FloorLeft
		elif right == utils.TileType.WALL:
			if top == utils.TileType.WALL:
				return Vector2i(4, 1)  # FloorTopRight
			elif bottom == utils.TileType.WALL:
				return Vector2i(4, 3)  # FloorBottomRight
			else:
				return Vector2i(4, 2)  # FloorRight
		elif bottom == utils.TileType.WALL:
			return get_random_texture([Vector2i(2, 3), Vector2i(3, 3)]) # FloorBottom
		elif top == utils.TileType.WALL:
			return get_random_texture([Vector2i(2, 1), Vector2i(3, 1)]) # FloorTop
		else:
			return get_random_texture([Vector2i(2, 2), Vector2i(3, 2)]) # FloorCenter
	elif current == utils.TileType.WALL:
		var wall_left_right = get_random_texture([Vector2i(6, 0), Vector2i(6, 1), Vector2i(6, 2)])  # WallLeftRight
		var wall_left = get_random_texture([Vector2i(0, 0), Vector2i(0, 1), Vector2i(0, 2)])  # WallLeft
		var wall_right = get_random_texture([Vector2i(5, 0), Vector2i(5, 1), Vector2i(5, 2)])  # WallRight
		var wall_bottom = get_random_texture([Vector2i(1, 4), Vector2i(2, 4), Vector2i(3, 4)])  # WallBottom
		var wall_top = get_random_texture([Vector2i(1, 0), Vector2i(2, 0), Vector2i(3, 0)])  # WallTop
		var wall_top_right = Vector2i(1, 5)  # WallTopRight
		var wall_top_left = Vector2i(0, 5)  # WallTopLeft
		var wall_bottom_right = Vector2i(5,4)  # WallBottomRight
		var wall_bottom_left = Vector2i(0,4)  # WallBottomLeft
		
		if bottom == utils.TileType.FLOOR:
			return wall_top
		elif top == utils.TileType.FLOOR:
			if left == utils.TileType.FLOOR and right == utils.TileType.FLOOR:
				return wall_left_right
			elif right == utils.TileType.FLOOR:
				if bottom_left == utils.TileType.FLOOR or bottom_left == utils.TileType.WALL:
					return wall_left_right
				return wall_top_right
			elif left == utils.TileType.FLOOR:
				if bottom_right == utils.TileType.FLOOR or bottom_right == utils.TileType.WALL:
					return wall_left_right
				else:
					return wall_top_left
			elif bottom == utils.TileType.WALL:
				if bottom_left == utils.TileType.OUTSIDE:
					return wall_top_right
				elif bottom_right == utils.TileType.OUTSIDE:
					return wall_top_left
				else:
					return wall_left_right
			else:
				return wall_bottom
		elif left == utils.TileType.FLOOR and right == utils.TileType.FLOOR:
			return wall_left_right
		elif left == utils.TileType.FLOOR:
			if right == utils.TileType.WALL:
				if bottom_right == utils.TileType.OUTSIDE:
					return wall_top_left
				else:
					return wall_left_right
			else: # RIGHT MUST BE OUTSIDE
				return wall_right
		elif right == utils.TileType.FLOOR:
			if left == utils.TileType.WALL:
				if bottom_left == utils.TileType.OUTSIDE:
					return wall_top_right
				else:
					return wall_left_right
			else: # LEFT MUST BE OUTSIDE
				return wall_left
		else: # NO FLOORS ON ALL SIDES
			if bottom == utils.TileType.OUTSIDE and right == utils.TileType.OUTSIDE:
				return wall_bottom_right
			elif bottom == utils.TileType.OUTSIDE and left == utils.TileType.OUTSIDE:
				return wall_bottom_left
			elif bottom == utils.TileType.OUTSIDE:
				return wall_bottom
			elif left == utils.TileType.OUTSIDE:
				return wall_left
			elif right == utils.TileType.OUTSIDE:
				return wall_right
			elif bottom_left == utils.TileType.OUTSIDE:
				return wall_top_right
			elif bottom_right == utils.TileType.OUTSIDE:
				return wall_top_left
			else:
				return wall_left_right
	return get_random_texture([Vector2i(8, 0), Vector2i(8, 1), Vector2i(7, 0), Vector2i(7, 1)])
