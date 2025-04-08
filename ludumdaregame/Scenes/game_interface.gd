extends Control

@onready var _health_bar: TextureProgressBar = $HealthBar
@onready var _score_label: Label = $TopRightBox/ScoreLabel
@onready var _dream_depth_label: Label = $TopRightBox/DreamDepthLabel
@onready var _level_label: Label = $LevelLabel

func update_ui(level: Node) -> void:
	var player = level.find_child("Player")
	var game = get_node_or_null("/root/Game")
	if player:
		_health_bar.set_value_no_signal(player.health)
	else:
		_health_bar.set_value_no_signal(0)
	var npc = game.npc_map[game.current_level]
	if npc:
		_level_label.set_text("Dreaming in:\n"+npc.npc_name)
	else:
		_level_label.set_text("")
	_score_label.set_text("Score: "+str(game.score))
	var dream_depth = len(game.level_stack)
	if dream_depth:
		_dream_depth_label.visible = true
		_dream_depth_label.set_text("Dream depth: " + str(dream_depth))
	else:
		_dream_depth_label.visible = false


func _process(_delta: float) -> void:
	var level = get_node_or_null("/root/Game/Level")
	if level == null:
		return
	update_ui(level)
