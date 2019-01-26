extends Node2D

const MAX_PLAYERS = 2

const Player = preload("res://player/Player.gd")

export (NodePath) var block_system_path
 
func _ready():
	assign_block_system_to_players()
		
		
func assign_block_system_to_players():
	for child in self.get_children():
		if child is Player:
			child.block_carrying.block_system = get_node(block_system_path)
			assert(child.block_carrying.block_system)
