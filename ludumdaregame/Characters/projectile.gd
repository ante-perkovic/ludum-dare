extends Area2D

@export var source: Node = null
var speed = 400


func _physics_process(delta):
	position += transform.x * speed * delta

func _on_bullet_body_entered(_body: Node2D):
	var body = _body.get_parent()  # We set up bodies 
	if body == source:
		return
	if body.is_in_group("enemy") or body.is_in_group("player"):
		body.take_damage(20)
	queue_free()
