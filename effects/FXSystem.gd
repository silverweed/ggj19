extends Node2D

const ExplFX = preload("res://block/ExplFX.tscn")
const BlockBreakFX = preload("res://block/BlockBreakFX.tscn")
const SmokeFX = preload("res://block/SmokeFX.tscn")

export (NodePath) var block_system_path

onready var block_system = get_node(block_system_path)

func _ready():
	assert(block_system)
	if !block_system.is_connected("blocks_collided", self, "on_blocks_collided"):
		block_system.connect("blocks_collided", self, "on_blocks_collided")
	if !block_system.is_connected("block_destroyed", self, "on_block_destroyed"):
		block_system.connect("block_destroyed", self, "on_block_destroyed")
		

func on_blocks_collided(ignore_direction : Vector2, pos : Vector2):
	var expl = ExplFX.instance()
	expl.play("default")
	add_child(expl)
	expl.global_position = pos
	var s = rand_range(6, 9)
	expl.scale = Vector2(s, s)
	

func on_block_destroyed(pos : Vector2):
	var fx = BlockBreakFX.instance()
	fx.emitting = true
	fx.restart()
	add_child(fx)
	fx.global_position = pos
	
	var smoke = SmokeFX.instance()
	smoke.play("default")
	add_child(smoke)
	smoke.global_position = pos - Vector2(0, 30)