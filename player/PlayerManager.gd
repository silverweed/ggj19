extends Node2D

const MAX_PLAYERS = 2

export (NodePath) var spawn_point_0_path
export (NodePath) var spawn_point_1_path

onready var spawn_point_0 = get_node(spawn_point_0_path).global_position
onready var spawn_point_1 = get_node(spawn_point_1_path).global_position
onready var p1 = $Player1
onready var p2 = $Player2
onready var players = [p1, p2]

const Player = preload("res://player/Player.gd")

export (NodePath) var block_system_path

var time_to_spawn = 3.4

 
func _ready():
	init_players()
	
		
func spawn_players():
	for i in range(players.size()):
		spawn_player(i)
	
		
func init_players():
	for child in self.get_children():
		if child is Player:
			child.connect("player_dead", self, "spawn_player")
			child.block_carrying.block_system = get_node(block_system_path)
			assert(child.block_carrying.block_system)



func spawn_player(id : int):
	var player = players[id]
	player.velocity.y = 0
	player.global_position = spawn_point_0 if id == 0 else spawn_point_1
	player.get_node("Spawn").play()

