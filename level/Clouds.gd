extends Node2D

const CloudTexture = preload("res://level/sprites/cloud_standard.png")

const MAX_SPAWN_X = 3000
const DESPAWN_X = 1500
const N_CLOUDS = 8

var clouds = []
var velocities = []

func _ready():
	randomize()
	for i in range(N_CLOUDS):
		spawn_cloud_at_random_pos()
		

func _process(delta):
	for i in range(clouds.size()):
		clouds[i].position.x += velocities[i] * delta
		if velocities[i] < 0 and clouds[i].position.x < -DESPAWN_X:
			clouds[i].position.x += 2 * DESPAWN_X + rand_range(-100, 100)
		elif velocities[i] > 0 and clouds[i].position.x > DESPAWN_X:
			clouds[i].position.x -= 2 * DESPAWN_X + rand_range(-100, 100)
			
	
func spawn_cloud_at_random_pos():
	var x = rand_range(-MAX_SPAWN_X, MAX_SPAWN_X)
	var y = rand_range(-300, 500)
	var cloud = Sprite.new()
	var sx = rand_range(1, 2)
	var sy = sx * rand_range(0.6, 1.6)
	
	cloud.texture = CloudTexture
	cloud.position = Vector2(x, y)
	cloud.scale = Vector2(sx, sy)
	cloud.modulate = calc_fade_color()
	
	clouds.append(cloud)
	velocities.append(rand_range(30, 100) * sign(-x))
	add_child(cloud)
	
	
func calc_fade_color() -> Color:
	var a = lerp(0.6, 1, 1.0 * clouds.size() / N_CLOUDS)
	return Color(a, a, min(1, a*1.1), 1)
		
	