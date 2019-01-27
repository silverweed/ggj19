extends Node

var accept_win = true
onready var main_theme = $"/root/MainTheme"

func _ready():
	for node in get_tree().get_nodes_in_group("houses"):
		if !node.is_connected("player_won", self, "on_player_won"):
			node.connect("player_won", self, "on_player_won")
	

func _input(event):
	if !accept_win and event.is_action_pressed("restart"):
		get_tree().paused = false
		main_theme.play()
		get_tree().change_scene_to(preload("res://tests/TestMap.tscn"))
	
	
func on_player_won(id):
	if !accept_win:
		return
		
	accept_win = false
	
	main_theme.stop()
	$WonTheme.play()
	$WinMenu.show()
		
	get_tree().paused = true
	
	
