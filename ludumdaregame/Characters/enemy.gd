extends CharacterBody2D

@export var enemy_move_speed: float = 150
@export var detection_radius: float = 100.0  # Distance to start chasing
@export var player: CharacterBody2D

var move_direction := Vector2.ZERO
var is_moving := false
var is_chasing := false
var health:int = 100;

@onready var behavior_timer := Timer.new()

func _ready():
	randomize()

	# Timer setup
	behavior_timer.wait_time = randf_range(1.5, 3.5)
	behavior_timer.one_shot = true
	behavior_timer.timeout.connect(_toggle_behavior)
	add_child(behavior_timer)

	# Start in idle or moving randomly
	is_moving = randi() % 2 == 0
	if is_moving:
		_change_direction()

	behavior_timer.start()

func _physics_process(_delta):
	if player:
		var distance_to_player = position.distance_to(player.position)

		# Chase player if close
		if distance_to_player < detection_radius:
			is_chasing = true
		elif distance_to_player > detection_radius + 30:  # Small buffer to prevent jitter
			is_chasing = false

	# --- MOVEMENT LOGIC ---
	if is_chasing:
		var direction_to_player = (player.position - position).normalized()
		velocity = direction_to_player * enemy_move_speed
	else:
		if is_moving:
			velocity = move_direction.normalized() * enemy_move_speed
			if get_last_slide_collision() != null:
				_change_direction()
		else:
			velocity = Vector2.ZERO

	move_and_slide()

func _toggle_behavior():
	if not is_chasing:
		is_moving = !is_moving

		if is_moving:
			_change_direction()
		else:
			move_direction = Vector2.ZERO

		# Restart timer for next toggle
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

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	# TODO: play animation
	queue_free()
