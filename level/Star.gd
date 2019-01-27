extends Sprite

onready var timer = $Timer

func _ready():
	timer.wait_time = rand_range(0.2, 6)
	
	
func _on_Timer_timeout():
	$AnimationPlayer.play("idle")
	timer.wait_time = rand_range(2, 10)