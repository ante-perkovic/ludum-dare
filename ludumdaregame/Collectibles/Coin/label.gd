extends Label

func _ready():
	
	var timer = Timer.new()
	timer.wait_time = 1
	timer.one_shot = true
	timer.autostart = true
	add_child(timer)
	timer.timeout.connect(queue_free)
	
