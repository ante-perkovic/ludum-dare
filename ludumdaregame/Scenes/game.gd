extends Node

var level_stack: Array = [] # Remembers level names in entry order
var level_map: Dictionary[int, Node] = {} # Remembers all levels by names (names are set by NPC script)
var npc_map: Dictionary[int, Node] = {}
var current_level: int = 0
var LevelScene = preload("Level.tscn")
var score: int = 0
var max_dream_depth: int = 0

var SCORE_KILL = 20
var SCORE_COIN = 10
var SCORE_DREAM = 30

func _ready():
	# Start the first level
	enter_level(1, null)

func _input(event):
	if event.is_action_pressed("prev_level_tmp"): # Escape
		return_to_previous_level()
	if event.is_action_pressed("exit"): # Escape
		get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")

func enter_level(level_name, npc):
	# Level name is defined by NPC it was entered in
	npc_map[level_name] = npc
	if current_level:
		level_stack.append(current_level)
	var previous_level = current_level

	var new_level = null
	if level_name not in level_map:
		if npc:
			score += SCORE_DREAM
		new_level = LevelScene.instantiate()
		level_map[level_name] = new_level
		if npc:
			new_level.create_level(npc.current_depth, npc.allowed_depth)
		else:
			new_level.create_level(1, -1)
	else:
		new_level = level_map[level_name]
		# TODO: Resetirati level nekako, da ima iste postavke ko na pocetku,
		# Ili ga resetati samo tako da se reseta playera na pocetak, mozda tako bolje
	current_level = level_name
	if previous_level:
		change_level(previous_level, current_level)
	else:
		add_child(level_map[current_level])
	if len(level_stack) > max_dream_depth:
		max_dream_depth = len(level_stack)

func return_to_previous_level():
	if level_stack.size() > 0:
		var previous_level = level_stack.pop_back()
		change_level(current_level, previous_level)
		current_level = previous_level

func game_over():
	var game_over_layer: Control = $GameInterfaceCanvas/MarginContainer/GameOver
	var ui_layer: Control = $GameInterfaceCanvas/MarginContainer/GameInterface
	var score_label: Label = game_over_layer.find_child("ScoreLabel")
	var dream_depth_label: Label = game_over_layer.find_child("DepthLabel")
	score_label.set_text("Score: "+str(score))
	dream_depth_label.set_text("Max dream depth: "+str(max_dream_depth))
	game_over_layer.visible = true
	ui_layer.visible = false

func change_level(prev_level: int, next_level: int):
	remove_child(level_map[prev_level])
	add_child(level_map[next_level])
