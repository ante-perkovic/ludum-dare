
extends Node2D

var FloatingTextScene = preload("res://Collectibles/Label.tscn")  # Adjust the path as needed


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.add_health()
		# Instance the floating text and set its position
		var floatingText = FloatingTextScene.instantiate()
		# Position it where the coin was, or adjust if needed for your UI
		floatingText.global_position = position  
		floatingText.modulate = Color(1,0.15,0.15)
		var text_label = floatingText.find_child("Text")
		text_label.set_text("+"+str(get_node("/root/Game").HEAL_AMMOUNT))
		# Add to the scene tree. You might want to add it to a CanvasLayer if you need it to render above everything.
		get_tree().get_root().add_child(floatingText)

		queue_free()
