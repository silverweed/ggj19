extends Node2D

export (NodePath) var block_system_path
onready var block_system = get_node(block_system_path)

export var block_n : int
export var area : int

onready var block_prefab = preload("res://block/Block.tscn")

var delay = 0
var blocks_left = 100

func _ready ():
	delay = 0;
	blocks_left = block_n


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if delay <= 0 and blocks_left > 0:
		var b = block_prefab.instance()
		add_child(b)
		b.position = Vector2(120 * (randi() % area), -3000)
		block_system.add_block(b)
		delay = 0.15
		blocks_left = blocks_left - 1
	else :
		delay -= delta
		
	
