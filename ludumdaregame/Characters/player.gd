extends CharacterBody2D
@export var player_move_speed: float = 150
@export var projectile_scene: PackedScene = preload("res://Characters/projectile.tscn")
var health: int = 100

var PLAYER_MOVE_SPEED_CROUCH = 50
var PLAYER_MOVE_SPEED_DEFAULT = 150
var PLAYER_MOVE_SPEED_SPRINT = 225

func _physics_process(_delta):
	#Get input direction
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")	
	)

	#print(input_direction)
	
	#Update velocity
	velocity = input_direction * player_move_speed
	
	#Move and Slide function uses velocity or character body to move the character on map
	move_and_slide()

# checks input events
func _input(event: InputEvent) -> void:
	
	# action - shoot
	if event.is_action_pressed("shoot"):
		shoot_projectile()
	
	# action - interact
	if event.is_action_pressed("interact"):
		interact_with_npc()
	
	# action - crouch
	if event.is_action_pressed("crouch"):
		$CollisionShape2D.shape.set_size(Vector2(12, 10))
		player_move_speed = PLAYER_MOVE_SPEED_CROUCH
		
	if event.is_action_released("crouch"):
		$CollisionShape2D.shape.set_size(Vector2(12, 25))
		player_move_speed = PLAYER_MOVE_SPEED_DEFAULT
		
# function for shooting
func shoot_projectile():
	
	# create projectile and set its position
	var projectile = projectile_scene.instantiate()
	projectile.source = self
	projectile.global_position = global_position
	
	# calc projectile direction
	var target: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (target-global_position).normalized()
	
	# set projectile velocity and rotate
	projectile.velocity = direction * projectile.speed
	projectile.rotation = direction.angle()
	
	# add projectile to scene tree
	get_parent().add_child(projectile)

# checks if there are NPCs nearby and enters their dream
func interact_with_npc():
	var nearby_npcs = $InteractionArea.get_overlapping_bodies()
	for npc in nearby_npcs:
		if npc.is_in_group("npc") and npc.is_dreaming:
			npc.enter_dream()
			return

func take_damage(amount: int):
	health -= amount
	if health <= 0:
		die()
	update_health_bar()

func die():
	var game_node = find_parent("Game")
	game_node.return_to_previous_level()
	queue_free()

func update_health_bar():
	var healthbar = get_node("CanvasLayer/HealthBar")
	healthbar.value = health
