extends CharacterBody2D
@export var player_move_speed: float = 150
@export var projectile_scene: PackedScene = preload("res://Characters/projectile.tscn")

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
	if event.is_action_pressed("spacebar"):
		shoot_projectile()
		
# function for shooting
func shoot_projectile():
	
	# create projectile and set its position
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	
	# calc projectile direction
	var target: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (target-global_position).normalized()
	
	# set projectile velocity and rotate
	projectile.velocity = direction * projectile.speed
	projectile.rotation = direction.angle()
	
	# add projectile to scene tree
	get_parent().add_child(projectile)
