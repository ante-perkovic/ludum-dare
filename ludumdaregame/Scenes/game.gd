extends Node

var level_stack: Array = []
var current_level: Node = null
var LevelScene = preload("Level.tscn")

func _ready():
	# Start the first level
	_create_new_level()

func _input(event):
	if event.is_action_pressed("next_level_tmp"): # T key
		_create_new_level()
	elif event.is_action_pressed("prev_level_tmp"): # Escape
		_return_to_previous_level()

func _create_new_level():
	if current_level:
		current_level.set_process(false)
		get_tree().paused = true
		level_stack.append(current_level)

	var new_level = LevelScene.instantiate()
	add_child(new_level)

	new_level.on_previous_level_callback = Callable(self, "_return_to_previous_level")
	new_level.on_next_level_callback = Callable(self, "_create_new_level")

	new_level.create_level()

	current_level = new_level
	get_tree().paused = false

func _return_to_previous_level():
	if current_level:
		current_level.queue_free()
		current_level = null

	if level_stack.size() > 0:
		var previous_level = level_stack.pop_back()
		current_level = previous_level
		current_level.set_process(true)
		get_tree().paused = false
