extends CharacterBody2D

@export var npc_move_speed: float = 100
var move_direction := Vector2.ZERO
var is_moving := false  # Track if NPC is currently moving

@onready var behavior_timer := Timer.new()

func _ready():
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
	print("u snu...")
