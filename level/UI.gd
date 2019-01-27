extends Control


var kills = []

func _ready():
	$CenterContainer/HBoxContainer/P0Kills.text = "Kills: 0"
	$CenterContainer/HBoxContainer/P1Kills.text = "Kills: 0"
	for player in get_tree().get_nodes_in_group("players"):
		kills.append(0)
		if !player.is_connected("player_dead", self, "on_player_dead"):
			player.connect("player_dead", self, "on_player_dead")
			
			
func on_player_dead(id):
	var label = $CenterContainer/HBoxContainer/P1Kills if id == 0 else $CenterContainer/HBoxContainer/P0Kills
	var i = 0 if id == 1 else 1
	kills[i] += 1
	label.text = "Kills: " + str(kills[i])