extends Control

var paused = false

func _unhandled_input(event):
	if event.is_action_pressed("pause"):
		set_paused(!paused)
		
		
func set_paused(p : bool):
	paused = p
	visible = paused
	get_tree().paused = paused
	$Moon.set_process(paused)