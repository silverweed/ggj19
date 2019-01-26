extends StaticBody2D

export (NodePath) var sky_path

onready var sky = get_node(sky_path)


func _ready():
	collision_layer |= preload("res://block/Block.gd").get_exclusive_collision_layer()
	

func _process(delta):
	modulate = sky.cur_modulate.lightened(0.5)