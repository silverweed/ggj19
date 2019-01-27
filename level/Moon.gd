extends Sprite


onready var timer = $Timer


func _ready():
	$HaloAnimPlayer.play("pulse")

func _on_Timer_timeout():
	$AnimationPlayer.play("idle")
	timer.wait_time = rand_range(2, 10)
