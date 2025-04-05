extends CharacterBody2D
@export var player_move_speed: float = 150

func _physics_process(_delta):
	#Get input direction
	var input_direction = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")	
	)

	print(input_direction)
	
	#Update velocity
	velocity = input_direction * player_move_speed
	
	#Move and Slide function uses velocity or character body to move the character on map
	move_and_slide()
