extends Node

var accept_win = true

func _ready():
	for node in get_tree().get_nodes_in_group("houses"):
		if !node.is_connected("player_won", self, "on_player_won"):
			node.connect("player_won", self, "on_player_won")
	
	timer.wait_time = rand_range(1, 10)
	timer.start()
	timer.connect("timeout", self, "animate")
	
		
func on_player_won(id):
	if !accept_win:
		return
		
	accept_win = false
