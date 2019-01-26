extends Node

################ UNUSED CLASS ###############

const PlayerSplatteredFX = preload("res://player/PlayerSplatteredFX.tscn")

var cached_fx = {}

func _ready():
	preinstance(PlayerSplatteredFX, 2)
	

func preinstance(fx_type, n : int):
	if !cached_fx.has(fx_type):
		cached_fx[fx_type] = []
	
	var cur = cached_fx[fx_type].size()
	while cur < n:
		var fx = fx_type.instance()
		assert(fx is Particles2D)
		fx.enabled = false
		fx.global_position = Vector2(-1000, -1000)
		cached_fx[fx_type].append(fx)
		
		cur += 1
		
		
func spawn(fx_type, pos : Vector2):
	pass