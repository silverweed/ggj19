extends Node2D

const MAX_PLAYERS = 2

const Player = preload("res://player/Player.gd")

export (NodePath) var block_system_path

var time_to_spawn = 5
 
func _ready():
	init_players()
	
		
func _process(delta):
	if time_to_spawn > 0:
		time_to_spawn -= delta
	elif time_to_spawn > -1:
		for child in self.get_children():
			if child is Player:
				if child.id == 1:
					child.velocity.y = 0
					child.global_position = Vector2(900, -2000)
				else:
					child.velocity.y = 0
					child.global_position = Vector2(-300, -2000)
		time_to_spawn = -10
		
		
		
		
func init_players():
	for child in self.get_children():
		if child is Player:
			child.connect("player_dead", self, "on_player_dead")
			child.block_carrying.block_system = get_node(block_system_path)
			assert(child.block_carrying.block_system)



func on_player_dead (id:int):
	for child in self.get_children():
		if child is Player and (child).id == id:
			if id == 1:
				child.velocity.y = 0
				child.global_position = Vector2(700, -2000)
			else:
				child.velocity.y = 0
				child.global_position = Vector2(-500, -2000)

