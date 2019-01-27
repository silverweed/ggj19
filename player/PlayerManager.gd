extends Node2D

const MAX_PLAYERS = 2

export (NodePath) var spawn_point_0_path
export (NodePath) var spawn_point_1_path

onready var spawn_point_0 = get_node(spawn_point_0_path).global_position
onready var spawn_point_1 = get_node(spawn_point_1_path).global_position

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
				child.velocity.y = 0
				if child.id == 1:
					child.global_position = spawn_point_1
				else:
					child.global_position = spawn_point_0
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
			child.velocity.y = 0
			if id == 1:
				child.global_position = spawn_point_1
			else:
				child.global_position = spawn_point_0

