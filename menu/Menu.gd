extends Control

const MAIN_SCENE = preload("res://tests/TestMap.tscn")


func set_expanded(node_path : String, expand : bool):
	var a = 1.3 if expand else 1.0
	var ctrl = get_node(node_path)
	ctrl.rect_scale = Vector2(a, a)


func _on_Play_pressed():
	$VBoxContainer/Play/Ok.play()
	get_tree().change_scene_to(MAIN_SCENE)


func _on_Quit_pressed():
	get_tree().quit()
