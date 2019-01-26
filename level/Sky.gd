extends Node2D

const DAY_COLOR = Color("ffffff")
const NIGHT_COLOR = Color("3d2375")

const DAYNIGHT_CYCLE = 60

var time = 0
var time_direction = 1
var progressive_time = 0

onready var sunmoon_start_rot = $SunMoonPivot.rotation

func _process(delta):
	time += delta * time_direction
	progressive_time += delta
	if time >= DAYNIGHT_CYCLE or time <= 0:
		time_direction *= -1
	
	if progressive_time >= 2 * DAYNIGHT_CYCLE:
		progressive_time = 0
		
	$Background.modulate = DAY_COLOR.linear_interpolate(NIGHT_COLOR, time / DAYNIGHT_CYCLE)
	$Clouds.modulate = $Background.modulate
	
	$SunMoonPivot.rotation = lerp(sunmoon_start_rot,
			sunmoon_start_rot + 2 * PI, 0.5 * progressive_time / DAYNIGHT_CYCLE)