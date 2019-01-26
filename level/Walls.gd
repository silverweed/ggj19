extends StaticBody2D

func _ready():
	collision_layer |= preload("res://block/Block.gd").get_exclusive_collision_layer()