extends CharacterBody2D
@export var projectile_scene: PackedScene = preload("res://Characters/projectile.tscn")
@export var weapon = preload("res://Weapons/Gun.tscn").instantiate()


var health: int = 100
var coins: int = 0

@export var player_move_speed: float = 150
var PLAYER_MOVE_SPEED_CROUCH = 50
var PLAYER_MOVE_SPEED_DEFAULT = 150
var PLAYER_MOVE_SPEED_SPRINT = 225

@onready var _animated_sprite = $AnimatedSprite2D

var _last_position: Vector2
var _is_interacting: bool

func _process(_delta):
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("right"):
		velocity.x += 1
	elif Input.is_action_pressed("left"):
		velocity.x -= 1
	if Input.is_action_pressed("down"):
		velocity.y += 1
	elif Input.is_action_pressed("up"):
		velocity.y -= 1
		
	if abs(velocity.x) > 0.1:
		_animated_sprite.flip_h = velocity.x > 0
	if _is_interacting:
		_animated_sprite.play("interact")
	else:
		if velocity.length() > 0.1:
			if _animated_sprite.animation != "running":
				_animated_sprite.play("running")
		else:
			if _animated_sprite.animation != "default":
				_animated_sprite.play("default")
	
	_last_position = global_position

func _ready():
	_last_position = global_position
	
	# give player a GUN
	weapon = preload("res://Weapons/Gun.tscn").instantiate()
	
	add_child(weapon)
	
	weapon.hide()

func _physics_process(_delta):
	#Get input direction
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")	
	)

	#print(input_direction)
	
	#Update velocity
	velocity = input_direction * player_move_speed
	
	if abs(velocity.x) > 0 and abs(velocity.y) > 0:
		velocity.x = velocity.x * sqrt(2)/2
		velocity.y = velocity.y * sqrt(2)/2
	
	#Move and Slide function uses velocity or character body to move the character on map
	if !_is_interacting:
		move_and_slide()
	

func set_up_interact_timer():
	var interact_timer = Timer.new()
	interact_timer.wait_time = 1
	interact_timer.one_shot = true
	interact_timer.autostart = true
	add_child(interact_timer)
	_is_interacting = true
	interact_timer.timeout.connect(Callable(self, "interact_with_npc"))

# checks input events
func _input(event: InputEvent) -> void:
	
	# action - shoots
	if event.is_action_pressed("shoot"):
		shoot_projectile()
	
	# action - interact
	if event.is_action_pressed("interact"):
		set_up_interact_timer()
	
	# action - crouch
	if event.is_action_pressed("crouch"):
		$CollisionShape2D.shape.set_size(Vector2(12, 10))
		player_move_speed = PLAYER_MOVE_SPEED_CROUCH
		
	if event.is_action_released("crouch"):
		$CollisionShape2D.shape.set_size(Vector2(12, 25))
		player_move_speed = PLAYER_MOVE_SPEED_DEFAULT
		
# function for shooting
func shoot_projectile():
	
	if weapon.fire() == false:
		return
	
	# create projectile and set its position
	var projectile = projectile_scene.instantiate()
	projectile.source = self
	projectile.global_position = global_position
	
	# calc projectile direction
	var target: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (target-global_position).normalized()
	var rng = RandomNumberGenerator.new()
	direction = direction.rotated(deg_to_rad(rng.randf_range(-weapon.spread_angle_degrees, weapon.spread_angle_degrees)))
	
	# set projectile velocity and rotate
	projectile.velocity = direction * projectile.speed
	projectile.rotation = direction.angle()
	
	# add projectile to scene tree
	get_parent().add_child(projectile)

# checks if there are NPCs nearby and enters their dream
func get_overlapping_npcs():
	var nearby_npcs
	if _animated_sprite.flip_h:
		nearby_npcs = $InteractionAreaRight.get_overlapping_bodies()
	else:
		nearby_npcs = $InteractionAreaLeft.get_overlapping_bodies()
	return nearby_npcs
	

func interact_with_npc():
	var nearby_npcs = get_overlapping_npcs()
	_is_interacting = false
	for npc in nearby_npcs:
		if npc.is_in_group("npc") and npc.is_dreaming:
			npc.enter_dream()
			return

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()

func die():
	var game = find_parent("Game")
	game.return_to_previous_level()
	if len(game.level_stack):
		queue_free()
	else:
		game.game_over()

func add_coin():
	coins += 1
	var game = find_parent("Game")
	game.score += game.SCORE_COIN

func add_health():
	health += 1

func _on_weapon_pickup_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("weapon"):
		push_error("pickup must be implemented!")
		weapon = body.instantiate_weapon()
