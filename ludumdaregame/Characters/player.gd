extends CharacterBody2D
@export var projectile_scene: PackedScene = preload("res://Characters/projectile.tscn")
@export var weapon = preload("res://Weapons/Gun.tscn").instantiate()

@onready var game = get_node("/root/Game")
var coins: int = 0

@export var player_move_speed: float = 150
var PLAYER_MOVE_SPEED_CROUCH = 50
var PLAYER_MOVE_SPEED_DEFAULT = 150
var PLAYER_MOVE_SPEED_SPRINT = 225

@onready var _animated_sprite = $AnimatedSprite2D
@onready var _blood_sprite = $AnimatedSprite2D/BloodSprite

var _last_position: Vector2
var _is_interacting: bool
var _prev_npc_move_speed = null

func _process(_delta):
	if game.health <= 0:
		return
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
	if game.health <= 0:
		return
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


func interact():
	var interactable = get_nearest_interactable()
	if interactable == null:
		return
	if interactable.is_in_group("npc"):
		interact_with_npc(interactable)
	elif interactable.is_in_group("beacon"):
		game.return_to_previous_level(false)

func interact_with_npc(npc):
	_prev_npc_move_speed = npc.npc_move_speed
	npc.npc_move_speed = 0
	var interact_timer = Timer.new()
	game.enter_dream_sound.play()
	interact_timer.wait_time = 1
	interact_timer.one_shot = true
	interact_timer.autostart = true
	add_child(interact_timer)
	_is_interacting = true
	interact_timer.timeout.connect(func(): finish_interact_with_npc(npc))


func finish_interact_with_npc(npc):
	npc.enter_dream()
	_is_interacting = false
	npc.npc_move_speed = _prev_npc_move_speed

# checks input events
func _input(event: InputEvent) -> void:
	if game.health <= 0:
		return
	# action - shoots
	if event.is_action_pressed("shoot"):
		shoot_projectile()
	
	# action - interact
	if event.is_action_pressed("interact"):
		interact()
	
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
	get_parent().add_child(projectile)
	projectile.source = self
	var target: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (target-global_position).normalized()
	var rng = RandomNumberGenerator.new()
	direction = direction.rotated(deg_to_rad(rng.randf_range(-weapon.spread_angle_degrees, weapon.spread_angle_degrees)))
	projectile.transform = Transform2D(direction.angle(), $AnimatedSprite2D/GunPosition.global_position)


func _get_interactable_bodies():
	var nearby_bodies = $InteractionArea.get_overlapping_bodies()
	var bodies = []
	for body in nearby_bodies:
		if body.is_in_group("beacon") or (body.is_in_group("npc") and body.is_dreaming):
			bodies.append(body)
	return bodies

func get_nearest_interactable():
	var nearest = null
	var bodies = _get_interactable_bodies()
	var nearest_dist = null
	for body in bodies:
		var dist = global_position.distance_to(body.global_position)
		if nearest_dist == null or dist < nearest_dist:
			nearest = body
			nearest_dist = dist
	return nearest

func take_damage(amount: int):
	if game.health <= 0:
		return
	game.health -= amount
	if game.health <= 0:
		die()

func die():
	game.game_over()
	$PlayerDeathSound.play()
	_animated_sprite.position += Vector2(0, 8)
	_animated_sprite.play("die")
	_animated_sprite.z_as_relative = false
	_animated_sprite.z_index = -1
	_blood_sprite.visible = true

func add_coin():
	coins += 1
	game.score += game.SCORE_COIN

func add_health():
	game.health += game.HEAL_AMMOUNT

func _on_weapon_pickup_area_body_entered(body: Node2D) -> void:
	# TODO
	if body.is_in_group("weapon"):
		push_error("pickup must be implemented!")
		weapon = body.instantiate_weapon()
