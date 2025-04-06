extends Node

var level_stack: Array = [] # Remembers level names in entry order
var level_map: Dictionary[int, Node] = {} # Remembers all levels by names (names are set by NPC script)
var current_level: int = 0
var LevelScene = preload("Level.tscn")

var local_level_counter = 1

func _ready():
	# Start the first level
	enter_level(local_level_counter)
	local_level_counter += 1

func _input(event):
	if event.is_action_pressed("next_level_tmp"): # T key
		enter_level(local_level_counter)
		local_level_counter += 1
	elif event.is_action_pressed("prev_level_tmp"): # Escape
		return_to_previous_level()


func enter_level(level_name):
	# Level name is defined by NPC it was entered in
	if current_level:
		# Pause current level, and add it to stack
		level_stack.append(current_level)
	var previous_level = current_level

	var new_level = null
	if level_name not in level_map:
		new_level = LevelScene.instantiate()
		
		#add_child(new_level)
		level_map[level_name] = new_level
		
		new_level.create_level()
	else:
		new_level = level_map[level_name]
		# TODO: Resetirati level nekako, da ima iste postavke ko na pocetku,
		# Ili ga resetati samo tako da se reseta playera na pocetak, mozda tako bolje
	current_level = level_name
	if previous_level:
		change_level(previous_level, current_level)
	else:
		add_child(level_map[current_level])

func return_to_previous_level():
	if level_stack.size() > 0:
		var previous_level = level_stack.pop_back()
		change_level(current_level, previous_level)
		current_level = previous_level
	else:
		# TODO Game over!
		pass

func change_level(prev_level: int, next_level: int):
	remove_child(level_map[prev_level])
	add_child(level_map[next_level])
