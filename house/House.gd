extends Area2D

signal player_won(id)

export var id = 0

const TEXTURES = [
	preload("res://house/sprites/house_evil.png"),
	preload("res://house/sprites/house_cyclops.png")
]
	
func _ready():
	$Sprite.texture = TEXTURES[id]
	
	
func _on_House_body_entered(body):
	if body.is_in_group("players") && body.id != id: #if body.is_in_group("players")
		emit_signal("player_won", body.id)
