extends Node

const MAX_PLAYERS = 2
const ACTIONS = ["move_left","move_right","grab_block","throw_block","jump"] 

const Player = preload("res://player/Player.gd")

var action_map = []

func _ready():
	set_managers()
	reset_map()

func _process(delta):
	reset_map()

func _input(event):
	for i in range(MAX_PLAYERS):
		for action in ACTIONS:
			if event.is_action_pressed(action+"_"+str(i)):
				action_map[i][action] = true
				return

func reset_map():
	for i in range(MAX_PLAYERS):
		var dictionary = {}
		for action in ACTIONS:
			dictionary[action]=false
		action_map.push_back(dictionary)
		
func set_managers():
	for child in self.get_children():
		if child is Player:
			child.player_manager = self
