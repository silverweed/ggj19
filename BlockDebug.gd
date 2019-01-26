extends Node2D


func _input(event):
	if event.is_action_pressed("throw_block"):
		$Block.throw(Vector2(-600, -600))
		$Block2.throw(Vector2(600, -600))