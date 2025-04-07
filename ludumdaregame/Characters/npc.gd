extends CharacterBody2D

@export var npc_move_speed: float = 100
var move_direction := Vector2.ZERO
var is_moving := false  # Track if NPC is currently moving

@onready var behavior_timer := Timer.new()
@export var is_dreaming = false # Track if this npc is a special NPC that is dreaming
@export var is_main_level = false # Will guarantee to recursiely go deeper and deeper

var level_id = null
@onready var _animated_sprite = $AnimatedSprite2D
var _last_position: Vector2

func _process(_delta):
	var velocity = (global_position - _last_position) / _delta
	if abs(velocity.x) > 0.1:
		_animated_sprite.flip_h = velocity.x > 0
	if velocity.length() > 0.1:
		if _animated_sprite.animation != "running":
			_animated_sprite.play("running")
	else:
		if _animated_sprite.animation != "default":
			_animated_sprite.play("default")
	_last_position = global_position
	
	var player = get_tree().get_nodes_in_group("player")[0]
	var npcs = player.get_overlapping_npcs()
	var label = get_node("Label")
	var is_overlapping = false
	for i in npcs:
		if i == self:
			is_overlapping = true
			break
	if is_overlapping:
		label.text = "E"
		label.show()
	else:
		label.hide()

func _body_entered(body: Node2D)->void:
	print(body)

func _ready():
	_last_position = global_position
	randomize()

	# Set up the behavior timer
	behavior_timer.wait_time = randf_range(1.5, 3.5)  # Random idle/move duration
	behavior_timer.one_shot = true
	behavior_timer.timeout.connect(_toggle_behavior)
	add_child(behavior_timer)

	# Start in idle or moving randomly
	is_moving = randi() % 2 == 0
	if is_moving:
		_change_direction()
	
	#print(player.get_overlapping_npcs())
	behavior_timer.start()
	

func _physics_process(_delta):
	if is_moving:
		velocity = move_direction.normalized() * npc_move_speed
		move_and_slide()

		# If collision, change direction
		if get_last_slide_collision() != null:
			_change_direction()
	else:
		velocity = Vector2.ZERO

func _toggle_behavior():
	is_moving = !is_moving  # Flip state

	if is_moving:
		_change_direction()
	else:
		move_direction = Vector2.ZERO

	# Randomize next wait time and restart the timer
	behavior_timer.wait_time = randf_range(1.5, 3.5)
	behavior_timer.start()

func _change_direction():
	var directions = [
		Vector2.LEFT,
		Vector2.RIGHT,
		Vector2.UP,
		Vector2.DOWN
	]

	directions.erase(move_direction)
	move_direction = directions[randi() % directions.size()]

func enter_dream():
	if level_id == null:
		level_id = randi() + 1
	var game_node = find_parent("Game")
	game_node.enter_level(level_id)
	
