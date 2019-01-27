extends KinematicBody2D

signal player_dead(id)

const Block = preload("res://block/Block.gd")
const PlayerSplatteredFX = preload("res://player/PlayerSplatteredFX.tscn")

const MAX_JUMPS = 1
const COOLDOWN_JUMP = 0.5
const NORMAL_GRAVITY = 150
const STRONG_GRAVITY = 210
const MAX_VELOCITY = 1000

export var id = -1

var jump_impulse = 2500
var jump_count = 0
var time_since_last_jump = 0
var jumped_last_frame = false

var airborne = false
var facing = 1

var velocity = Vector2()

const MAX_ACCELERATION = 10
const MIN_ACCELERATION = 0.1
var deceleration = 40
var speed = 600
var gravity = Vector2(0, NORMAL_GRAVITY)
var prev_velocity = Vector2(1, 0)

var safety_timer = 0

onready var block_carrying = $GrabBlockArea

	
static func get_exclusive_collision_layer() -> int:
	return 1 << 5

func _enter_tree():
	if id == 1:
		prev_velocity.x = - 1
		scale.x *= -1
		facing *= -1
	collision_layer |= get_exclusive_collision_layer()
	

func _ready():
	$AnimatedSprite.play("idle_" + str(id))
	
	
func _physics_process(delta):
	var wished_dir = compute_wished_dir()
	
	if wished_dir == 0:
		var current_velocity = velocity.x
		velocity.x -= deceleration * sign(velocity.x)
		if sign(velocity.x) != sign(current_velocity):
			velocity.x = 0
	
	var acceleration = calc_acceleration(wished_dir)
	velocity.x = clamp(velocity.x + speed * acceleration * delta, -MAX_VELOCITY, MAX_VELOCITY)
	
	velocity += gravity
	
	process_jump(delta)
	
	velocity = move_and_slide(velocity, Vector2(0, -1))
	
	if is_on_floor():
		if $GrabBlockArea.carried_block == null:
			if velocity.x != 0:
				$AnimatedSprite.play("walk_" + str(id))
			else: 
				$AnimatedSprite.play("jump_" + str(id))
		else:
			if velocity.x != 0:
				$AnimatedSprite.play("walk_grab_" + str(id))
			else: 
				$AnimatedSprite.play("idle_grab_" + str(id))
		
		velocity.y = 0
		jump_count = 0
		airborne = false 
	else: 
		airborne = true
	
	flip_player_when_direction_changes()
		

func _input(event):
	if event.is_action_pressed("jump_" + str(id)):
		jump()
	if Input.is_action_pressed("suicide_" + str(id)):
		die()



func jump():
	if jump_count < MAX_JUMPS && time_since_last_jump >= COOLDOWN_JUMP:
		velocity.y -= jump_impulse
		jump_count += 1
		time_since_last_jump = 0
		gravity.y = NORMAL_GRAVITY
		jumped_last_frame = true
		$Jump.play()


func calc_acceleration(wished_dir : int):
	var delta_v = abs(MAX_VELOCITY * wished_dir - velocity.x) / MAX_VELOCITY
	return wished_dir * lerp(MIN_ACCELERATION, MAX_ACCELERATION, delta_v) 


func flip_player_when_direction_changes():
	if velocity.x != 0:
		if sign(velocity.x) != sign(prev_velocity.x):
			scale.x *= -1
			facing *= -1
		prev_velocity = velocity
		
		
func process_jump(delta):
	time_since_last_jump += delta
		
	if jumped_last_frame:
		jumped_last_frame = false
	elif velocity.y != 0 && sign(velocity.y) != sign(prev_velocity.y):
		gravity.y = STRONG_GRAVITY
		
		
func compute_wished_dir() -> int:
	var wished_dir = 0
	if Input.is_action_pressed("move_left_" + str(id)):
		wished_dir = -1
	elif Input.is_action_pressed("move_right_" + str(id)):
		wished_dir = 1
	return wished_dir
	

func try_kill(body : PhysicsBody2D):
	if !body.is_in_group("hurting_player"):
		return
	
	assert (body is Block)
	if(block_carrying.block_system.is_sleeping(body)):
		return;
	
	
	var diff = global_position - body.global_position
	if diff.dot(body.cur_velocity) > 0:
		die()
		

		
func die():
	var splatter_fx = PlayerSplatteredFX.instance()
	splatter_fx.emitting = true
	splatter_fx.restart()
	get_parent().add_child(splatter_fx)
	splatter_fx.global_position = global_position
	emit_signal("player_dead", id)
	$Splat.play()
