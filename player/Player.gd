extends KinematicBody2D

const Block = preload("res://block/Block.gd")

var throw_impulse = Vector2(1500, -500)
var jump_impulse = 2000
var velocity = Vector2()
var speed = 500
var gravity = Vector2(0, 100)

var grabbable_block : Block = null
var prev_velocity = Vector2(1, 0)

func _physics_process(delta):
	velocity.x = 0
	if Input.is_action_pressed("move_left"):
		velocity.x -= speed
	if Input.is_action_pressed("move_right"):
		velocity.x += speed
	
	velocity += gravity
	
	#move_and_collide(norm_velocity * delta)
	move_and_slide(velocity, Vector2(0, -1))
	if is_on_floor():
		velocity.y = 0
	
	if velocity.x != 0:
		if sign(velocity.x) != sign(prev_velocity.x):
			scale.x *= -1
		prev_velocity = velocity
		

func _input(event):
	if event.is_action_pressed("throw_block"):
		if grabbable_block:
			grabbable_block.throw(throw_impulse)
	elif event.is_action_pressed("jump"):
		velocity.y -= jump_impulse


func _on_GrabBlockArea_body_entered(body):
	if body.is_in_group("blocks"):
		grabbable_block = body as Block

func _on_GrabBlockArea_body_exited(body):
	if body == grabbable_block:
		grabbable_block = null
