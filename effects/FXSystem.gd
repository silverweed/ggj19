extends Node2D

const ExplFX = preload("res://block/ExplFX.tscn")

export (NodePath) var block_system_path

onready var block_system = get_node(block_system_path)

func _ready():
	assert(block_system)
	if !block_system.is_connected("blocks_collided", self, "on_blocks_collided"):
		block_system.connect("blocks_collided", self, "on_blocks_collided")
		

func on_blocks_collided(ignore_direction : Vector2):
	var expl = ExplFX.instance()
	expl.global_position = Vector2(200, 200)
	add_child(expl)