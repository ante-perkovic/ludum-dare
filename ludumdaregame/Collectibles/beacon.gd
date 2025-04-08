extends Node2D

@onready var _animated_interaction: AnimatedSprite2D = $AnimatedInteraction


func _process(_delta):
	var player = get_node("../Player")
	var nearest = player.get_nearest_interactable()
	if nearest == self:
		_animated_interaction.play("default")
		_animated_interaction.show()
	else:
		_animated_interaction.hide()
