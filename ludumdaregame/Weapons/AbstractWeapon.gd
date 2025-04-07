extends Node2D

@export var damage: int = -1
@export var rate_of_fire: int = -1
@export var spread_angle_degrees: float = -1.0
@export var weapon_name = ""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func fire():
	push_error("fire must be implemented!")

func instantiate_weapon():
	push_error("fire must be implemented!")
