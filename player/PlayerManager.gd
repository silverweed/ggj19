extends Node



const MAX_PLAYERS = 2
const ACTIONS = ["move_left","move_right","grab_block","throw_block","jump"]
var player0 
var player1

var action_map = []

func _ready():
	resetMap()

func _process(delta):
	resetMap()

func _input(event):
	for i in range(MAX_PLAYERS):
		for action in ACTIONS:
			if event.is_action_pressed(action+"_"+str(i)):
				action_map[i][action] = true
				return

func resetMap():
	for i in range(MAX_PLAYERS):
		var dictionary = {}
		for action in ACTIONS:
			dictionary[action]=false
		action_map.push_back(dictionary)
