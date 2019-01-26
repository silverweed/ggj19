extends KinematicBody2D

const Block = preload("res://block/Block.gd")

const MAX_JUMPS = 1 #TODO double jumps
const COOLDOWN_JUMP = 0.5
const NORMAL_GRAVITY = 150
const STRONG_GRAVITY = 210
const MAX_VELOCITY = 1000

# todo raccogliere blocchi => sotto di te
# todo gravità non lineare nel salto gravità iniziale X gravità X++
	#velocità y negativa, poi cambia segno
# todo wall jump
# todo muore con un tasto
# todo respawn
# to know scale positiva verso destra negativa verso sinistra 0;0 in alto a sinistra, gravità positiva


var throw_impulse = Vector2(500, -500)

var jump_impulse = 3000
var jump_count = 0
var time_since_last_jump = 0
var jumped_last_frame = false

var velocity = Vector2()

const MAX_ACCELERATION = 10
const MIN_ACCELERATION = 0.1
var deceleration = 40
var speed = 600
var gravity = Vector2(0, NORMAL_GRAVITY)

var grabbable_block : Block = null
var prev_velocity = Vector2(1, 0)

func _physics_process(delta):
	var wished_dir = 0
	if Input.is_action_pressed("move_left"):
		wished_dir = -1
	elif Input.is_action_pressed("move_right"):
		wished_dir = 1
	elif velocity.x != 0:
		var current_velocity = velocity.x
		velocity.x -= deceleration * sign(velocity.x)
		if sign(velocity.x) != sign(current_velocity):
			velocity.x = 0
	
	var acceleration = calc_acceleration(wished_dir)
	velocity.x = clamp(velocity.x + speed * acceleration * delta, -MAX_VELOCITY, MAX_VELOCITY)
	
	print(gravity)
	velocity += gravity
	time_since_last_jump += delta
	
	if jumped_last_frame:
		jumped_last_frame = false
	elif velocity.y != 0 && sign(velocity.y) != sign(prev_velocity.y):
		gravity.y = STRONG_GRAVITY
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	if is_on_floor():
		velocity.y = 0
		jump_count = 0
	
	# Flip player
	if velocity.x != 0:
		if sign(velocity.x) != sign(prev_velocity.x):
			scale.x *= -1
		prev_velocity = velocity
		

func _input(event):
	if event.is_action_pressed("throw_block"):
		if grabbable_block:
			grabbable_block.throw(throw_impulse)
	elif event.is_action_pressed("jump"):
		jump()


func _on_GrabBlockArea_body_entered(body):
	if body.is_in_group("blocks"):
		grabbable_block = body as Block


func _on_GrabBlockArea_body_exited(body):
	if body == grabbable_block:
		grabbable_block = null


func jump():
	if jump_count < MAX_JUMPS && time_since_last_jump >= COOLDOWN_JUMP:
		velocity.y -= jump_impulse
		jump_count += 1
		time_since_last_jump = 0
		gravity.y = NORMAL_GRAVITY
		jumped_last_frame = true


func calc_acceleration(wished_dir : int):
	var delta_v = abs(MAX_VELOCITY * wished_dir - velocity.x) / MAX_VELOCITY
	return wished_dir * lerp(MIN_ACCELERATION, MAX_ACCELERATION, delta_v) 
