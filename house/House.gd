extends StaticBody2D

export var id = 0

const TEXTURES = [
	preload("res://house/sprites/house_base_01.png"),
	preload("res://house/sprites/house_base_02.png")
]
	
func _ready():
	$Sprite.texture = TEXTURES[id]