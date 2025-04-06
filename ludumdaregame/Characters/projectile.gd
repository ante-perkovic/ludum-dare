extends Node2D


var velocity: Vector2 = Vector2.ZERO
@export var source: Node = null

@export var speed = 1000

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta

# called when something enteres body
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == source:
		return
	
	# check if body is enemy
	if body.is_in_group("enemy"):
		body.take_damage(20)
		queue_free()
	
	if body.is_in_group("player"):
		body.take_damage(20)
	
		# destroy obj
		queue_free()

# TODO:
# destroy when out of map
