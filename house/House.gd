extends Area2D

signal player_won(id)

export var id = 0

const TEXTURES = [
	preload("res://house/sprites/house_base_01.png"),
	preload("res://house/sprites/house_base_02.png")
]
	
func _ready():
	$Sprite.texture = TEXTURES[id]
	
	
func _on_House_body_entered(body):
	if body.is_in_group("players"):
		emit_signal("player_won", body.id)