extends Node

export (NodePath) var block_system_path
export (NodePath) var screenshake_system_path

onready var block_system = get_node(block_system_path)
onready var screenshake_system = get_node(screenshake_system_path)

func _ready():
	assert(block_system)
	assert(screenshake_system)
	block_system.connect("blocks_collided", self, "on_blocks_collided")
	

func on_blocks_collided():
	print("blocks collided")
	screenshake_system.screenshake(200, 0.2)