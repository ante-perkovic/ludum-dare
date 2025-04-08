extends Area2D

@export var source: Node = null
@onready var shoot_sound: AudioStreamPlayer2D = $ShootSound
var speed = 340

var moved = false

func _physics_process(delta):
	position += transform.x * speed * delta
	if not moved:
		moved = true
		shoot_sound.reparent(get_node("/root/Game/Level"), true)
		shoot_sound.finished.connect(shoot_sound.queue_free)
		shoot_sound.play()

func _on_bullet_body_entered(_body: Node2D):
	var body = _body.get_parent()  # We set up bodies 
	if body == source:
		return
	if body.is_in_group("enemy") or body.is_in_group("player"):
		body.take_damage(20)
	queue_free()
