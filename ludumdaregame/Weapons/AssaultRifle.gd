extends Node2D

@export var damage: int = 10
@export var rate_of_fire: int = 4
@export var spread_angle_degrees: float = 10.0
@export var weapon_name: String = 'assault_rifle'

var can_fire: bool = true
var shoot_timer: Timer = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame
func _process(delta: float) -> void:
	pass

func fire() -> bool:
	if can_fire == true:
		# can_fire = false
		
		var shoot_timer = Timer.new()
		shoot_timer.wait_time = 1 / rate_of_fire
		shoot_timer.one_shot = true
		shoot_timer.autostart = true
		shoot_timer.timeout.connect(Callable(self, "reload"))
		add_child(shoot_timer)
		
		return true
	return false

func reload():
	can_fire = true

func instantiate_weapon():
	return preload("res://Weapons/AssaultRifle.tscn").instantiate()
