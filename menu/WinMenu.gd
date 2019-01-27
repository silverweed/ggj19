extends Control

var hasWon = false

func _unhandled_input(event):
	if event.is_action_pressed("win"):
		set_paused(!win)
		
		
func set_win(win : bool):
	hasWon = win
	visible = win
	get_tree().paused = win
	$Moon.set_process(win)