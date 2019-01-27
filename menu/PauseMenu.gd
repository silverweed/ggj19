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


func _on_Quit_pressed():
	get_tree().paused = false
	get_tree().change_scene("res://menu/Menu.tscn")


func set_expanded(node_path : String, expand : bool):
	var a = 1.3 if expand else 1
	var ctrl = get_node(node_path)
	ctrl.rect_scale = Vector2(a, a)
