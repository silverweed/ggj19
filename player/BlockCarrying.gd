extends Area2D

# This is a component of Player

const Block = preload("res://block/Block.gd")
const BlockSystem = preload("res://block/BlockSystem.gd")

const THROW_AXIS_DEADZONE = 0.1
const COLLIDER_OFFSET = 26

var grabbable_block : Block = null
var carried_block : Block = null
# This is set by PlayerManager
var block_system : BlockSystem = null

var throw_impulse = 4000
var throw_direction = Vector2()


onready var owner_id = get_parent().id


func _draw():
	draw_line(Vector2(), calc_throw_vector(), Color.red)
	
	
func _process(delta):
	update()
	if carried_block:
		carried_block.global_position = $BlockCarryingPos.global_position #+Vector2(0,-COLLIDER_OFFSET)
		carried_block.set_collider_disabled(true)
		

func _input(event):	
	if event.is_action_pressed("throw_block_" + str(owner_id)):
		if carried_block:
			carried_block.set_collider_disabled(false)
			carried_block.throw(calc_throw_vector())
			carried_block = null
		
		elif grabbable_block:
			carried_block = grabbable_block
			grabbable_block = null

	
func calc_throw_vector() -> Vector2:
#	var mouse_pos = get_global_mouse_position()
#	return (mouse_pos - global_position).normalized() * throw_impulse * sign(scale.x)
	var axis = Vector2(
		Input.get_action_strength("move_right_" + str(owner_id)) - \
			Input.get_action_strength("move_left_" + str(owner_id)),
			
		Input.get_action_strength("move_down_" + str(owner_id)) - \
			Input.get_action_strength("move_up_" + str(owner_id))
		)
	
	if axis.length_squared() < THROW_AXIS_DEADZONE:
		return Vector2(sign(scale.x), -0.2).normalized() * throw_impulse

	return axis.normalized() * throw_impulse
	
	

func _on_GrabBlockArea_body_entered(body):
	if body.is_in_group("blocks") and !carried_block:
		var block = body as Block
		if block_system.is_sleeping(block) and block.can_be_grabbed():
			grabbable_block = block


func _on_GrabBlockArea_body_exited(body):
	if body == grabbable_block:
		grabbable_block = null