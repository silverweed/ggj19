extends Node2D

onready var timer = $Timer

func _ready():
	timer.wait_time = rand_range(1, 10)
	
	
func animate():
	$AnimationPlayer.play("idle")
	timer.wait_time = rand_range(5, 10)
	