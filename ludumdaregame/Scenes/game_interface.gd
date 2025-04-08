extends Control

@onready var _health_bar: TextureProgressBar = $HealthBar
@onready var _score_label: Label = $TopRightBox/ScoreLabel
@onready var _level_label: Label = $LevelLabel
@onready var game = get_node("/root/Game")

func update_ui(level: Node) -> void:
	_health_bar.set_value_no_signal(game.health)
	if game.npc_map[game.current_level]:
		var text = "Dreaming in:\n"
		var total_levels = len(game.level_stack)
		if total_levels >= 4:
			text += "... - "
		for i in range(max(total_levels - 2, 1), total_levels):
			var npc = game.npc_map[game.level_stack[i]]
			text += npc.npc_name + " - "
		text += game.npc_map[game.current_level].npc_name
		text.erase(-3, 3)
		_level_label.set_text(text)
	else:
		_level_label.set_text("")
	_score_label.set_text("Score: "+str(game.score))


func _process(_delta: float) -> void:
	var level = get_node_or_null("/root/Game/Level")
	if level == null:
		return
	update_ui(level)
