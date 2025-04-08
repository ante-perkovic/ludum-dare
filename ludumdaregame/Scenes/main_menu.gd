extends Control


func _ready() -> void:
	$VBoxContainer/PlayButton.grab_focus()


func _input(event):
	if event.is_action_pressed("exit"): # Escape
		get_tree().quit()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Game.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
