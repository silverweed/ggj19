extends Node

var accept_win = true
onready var main_theme = $"/root/MainTheme"

func _ready():
	for node in get_tree().get_nodes_in_group("houses"):
		if !node.is_connected("player_won", self, "on_player_won"):
			node.connect("player_won", self, "on_player_won")
	
		
func on_player_won(id):
	main_theme.stop()
	$WonTheme.play()
	if !accept_win:
		return
		
	accept_win = false
	self.get_tree().paused = true
