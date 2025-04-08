extends CharacterBody2D

@export var npc_move_speed: float = 100
var move_direction := Vector2.ZERO
var is_moving := false  # Track if NPC is currently moving

@onready var behavior_timer := Timer.new()
var is_dreaming = false # Track if this npc is a special NPC that is dreaming
var current_depth = 0  # Unused if is_dreaming = false
var allowed_depth = 0  # Unused if is_dreaming = false

var level_id = null
var npc_name = null
@onready var _name_label = $NameLabel
@onready var _animated_sprite = $AnimatedSprite2D
@onready var _animated_interaction = $AnimatedInteraction
var _last_position: Vector2
var npc_animation_name = null

var npc_animation_name_list = ["bruce", "tenzin", "jimmy"]


func set_npc_name(name: String) -> void:
	npc_name = name
	if _name_label:
		_name_label.text = npc_name
		_name_label.visible = true
		if is_dreaming:
			if name == "The Chosen One":
				_name_label.modulate = Color(0.15, 0.15, 1)
			elif allowed_depth == -1:
				_name_label.modulate = Color(1, 0.3, 0.3)
			else:
				_name_label.modulate = Color(1, 1, 0.3)

func _process(_delta):
	var velocity = (global_position - _last_position) / _delta
	if abs(velocity.x) > 0.1:
		_animated_sprite.flip_h = velocity.x > 0
	if velocity.length() > 0.1:
		if _animated_sprite.animation != npc_animation_name+"_running":
			_animated_sprite.play(npc_animation_name+"_running")
	else:
		if _animated_sprite.animation != npc_animation_name+"_default":
			_animated_sprite.play(npc_animation_name+"_default")
	_last_position = global_position
	
	var player = get_node("../Player")
	var nearest = player.get_nearest_interactable()
	if nearest == self:
		_animated_interaction.play(npc_animation_name+"_default")
		_animated_interaction.show()
	else:
		_animated_interaction.hide()

func _body_entered(body: Node2D)->void:
	print(body)

func _ready():
	npc_animation_name = npc_animation_name_list[randi()%len(npc_animation_name_list)]
	_last_position = global_position
	if npc_name:
		set_npc_name(npc_name)
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
	game_node.enter_level(level_id, self)
	
