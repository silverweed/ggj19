extends Node

const MAX_CONCURRENT_SOUNDS = 6

const SOUNDS = {
	"blocks_collide": preload("res://block/sounds/block_impact.ogg"),
	"blocks_destroying": preload("res://block/sounds/block_impact.ogg")
}

export (NodePath) var block_system_path

onready var block_system = get_node(block_system_path)

var sound_players = []

func _ready():
	assert(block_system)
	
	create_sound_players()
	
	if !block_system.is_connected("blocks_collided", self, "on_blocks_collided"):
		block_system.connect("blocks_collided", self, "on_blocks_collided")
	
		
func create_sound_players():
	for i in range(MAX_CONCURRENT_SOUNDS):
		var player = AudioStreamPlayer.new()
		sound_players.append(player)
		add_child(player)
		
		
func on_blocks_collided(ignore_direction : Vector2, ignore_pos : Vector2):
	for player in sound_players:
		if !player.playing:
			player.stream = SOUNDS["blocks_collide"]
			player.play()
			return
	
	# No free players found: evict random one
	var i = randi() % sound_players.size()
	var player = sound_players[i]
	player.stop()
	player.stream = SOUNDS["blocks_collide"]
	player.play()