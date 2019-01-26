extends KinematicBody2D

const Block = preload("res://block/Block.gd")

const MAX_JUMPS = 1
const COOLDOWN_JUMP = 0.5
const NORMAL_GRAVITY = 150
const STRONG_GRAVITY = 210
const MAX_VELOCITY = 1000


var player_manager = null;

var throw_impulse = 1500

var jump_impulse = 2500
var jump_count = 0
var time_since_last_jump = 0
var jumped_last_frame = false

var velocity = Vector2()

const MAX_ACCELERATION = 10
const MIN_ACCELERATION = 0.1
var deceleration = 40
var speed = 600
var gravity = Vector2(0, NORMAL_GRAVITY)
var prev_velocity = Vector2(1, 0)

var grabbable_block : Block = null
var carried_block : Block = null

export(NodePath) var block_system_path

onready var block_system = get_node(block_system_path)
onready var splatter_fx = $FX/Splatter

func _ready():
	assert(block_system)
	
	
func _physics_process(delta):
	update()
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
		velocity.y = 0
		jump_count = 0
	
	flip_player_when_direction_changes()
	
	if carried_block:
		carried_block.global_position = $BlockCarryingPos.global_position
		

func _input(event):
	if event.is_action_pressed("throw_block"):
		if carried_block:
			carried_block.throw(calc_throw_vector())
			carried_block = null
		
		elif grabbable_block:
			carried_block = grabbable_block
			grabbable_block = null
		
	elif event.is_action_pressed("jump"):
		jump()


func _on_GrabBlockArea_body_entered(body):
	if body.is_in_group("blocks") and !carried_block:
		var block = body as Block
		if block_system.is_sleeping(block) and block.can_be_grabbed():
			grabbable_block = block


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


func flip_player_when_direction_changes():
	if velocity.x != 0:
		if sign(velocity.x) != sign(prev_velocity.x):
			scale.x *= -1
		prev_velocity = velocity
		
		
func process_jump(delta):
	time_since_last_jump += delta
		
	if jumped_last_frame:
		jumped_last_frame = false
	elif velocity.y != 0 && sign(velocity.y) != sign(prev_velocity.y):
		gravity.y = STRONG_GRAVITY
		
		
func compute_wished_dir() -> int:
	var wished_dir = 0
	if Input.is_action_pressed("move_left"):
		wished_dir = -1
	elif Input.is_action_pressed("move_right"):
		wished_dir = 1
	return wished_dir
	
	
func calc_throw_vector() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	return (mouse_pos - global_position).normalized() * throw_impulse * sign(scale.x)
	

func _on_Hitbox_body_entered(body : PhysicsBody2D):
	if !body.is_in_group("hurting_player"):
		return
	
	var diff = global_position - body.global_position
	if diff.dot(body.cur_velocity) < 0:
		die()
		
		
func die():
	splatter_fx.emitting = true
	splatter_fx.restart()
	