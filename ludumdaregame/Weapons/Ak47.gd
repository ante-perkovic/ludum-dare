extends Node2D
@export var projectile_scene: PackedScene = preload("res://Characters/projectile.tscn")
@export var damage: int = 10
@export var rate_of_fire: int = 6.9
@export var spread_angle_degrees: float = 30.0
@export var weapon_name: String = 'ak47'
@onready var sound: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var weapon_scene: PackedScene = preload("res://Weapons/Ak47.tscn")

var can_fire: bool = true
var shoot_timer: Timer = null

func shoot():
	var projectile = projectile_scene.instantiate()
	get_parent().get_parent().add_child(projectile)
	projectile.source = get_parent() 
	var target: Vector2 = get_global_mouse_position()
	var direction: Vector2 = (target-get_parent().global_position).normalized()
	var rng = RandomNumberGenerator.new()
	direction = direction.rotated(deg_to_rad(rng.randf_range(-spread_angle_degrees, spread_angle_degrees)))
	var gun_position =  get_parent().get_node("AnimatedSprite2D/GunPosition").global_position
	if get_parent()._animated_sprite.flip_h:
		gun_position.x += abs(gun_position.x - get_parent().global_position.x) * 2
	projectile.transform = Transform2D(direction.angle(), gun_position)

func reload():
	can_fire = true
	
func _ready():
	add_to_group("gun")
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not body.has_weapon_of_type(weapon_scene):
		var new_weapon = weapon_scene.instantiate()
		body.set_weapon(new_weapon)
		sound.reparent(get_node("/root/Game/Level"), true)
		sound.finished.connect(sound.queue_free)
		sound.play()
		queue_free()
