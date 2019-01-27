extends Area2D

# This is a component of Player

const Block = preload("res://block/Block.gd")

const THROW_AXIS_DEADZONE = 0.1
const BLOCK_CLD_DISABLE_TIME_AFTER_THROW = 0.2

var grabbable_block : Block = null
var carried_block : Block = null
# This is set by PlayerManager
var block_system = null

var throw_impulse = 4000
var offset = 100
var recoil = 3000

onready var owner_id = get_parent().id


func _draw():
	var axis = Vector2(
	Input.get_action_strength("aim_right_" + str(owner_id)) - \
		Input.get_action_strength("aim_left_" + str(owner_id)), \
		Input.get_action_strength("aim_down_" + str(owner_id)) - \
		Input.get_action_strength("aim_up_" + str(owner_id))
		)
	#draw_line(Vector2(), 100 * axis + Vector2(10, 10), Color.red)
	
	
func _process(delta):
	update()
	if carried_block:
		carried_block.global_position = $BlockCarryingPos.global_position
		carried_block.set_collider_disabled(true)
		

func _input(event):	
	
	if event.is_action_pressed("throw_block_" + str(owner_id)):
		if carried_block:
		
			var throw_dir = calc_throw_vector() 
			carried_block.set_collider_disabled(false)
			carried_block.disable_main_collider_for(BLOCK_CLD_DISABLE_TIME_AFTER_THROW)
			carried_block.throw(throw_dir * throw_impulse)
			carried_block.global_position += throw_dir * offset
			carried_block = null
			if owner.airborne:
				owner.velocity -= throw_dir * recoil
				owner.global_position -= throw_dir * offset
			$Throw.play()
		
		elif grabbable_block:
			$PickUp.play()
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
		return Vector2(sign(owner.facing), -0.1).normalized()

	axis += Vector2(0, -0.2)
	return axis.normalized()
	
func calc_throw_vector_alternative():
#	var mouse_pos = get_global_mouse_position()
#	return (mouse_pos - global_position).normalized() * throw_impulse * sign(scale.x)

	var axis = Vector2(
		Input.get_action_strength("aim_right_" + str(owner_id)) - \
			Input.get_action_strength("aim_left_" + str(owner_id)), \
			Input.get_action_strength("aim_down_" + str(owner_id)) - \
			Input.get_action_strength("aim_up_" + str(owner_id))
		)
		
	print(Input.get_action_strength("aim_up_" + str(owner_id)))
	
	if axis.length_squared() < THROW_AXIS_DEADZONE:
		return 0

	carried_block.set_collider_disabled(false)
	carried_block.disable_main_collider_for(BLOCK_CLD_DISABLE_TIME_AFTER_THROW)
	carried_block.throw(axis.normalized() * throw_impulse)
	carried_block = null
	$Throw.play()

	return 


func _on_GrabBlockArea_body_entered(body):
	if body.is_in_group("blocks") and !carried_block:
		var block = body as Block
		if block_system.is_sleeping(block) and block.can_be_grabbed():
			grabbable_block = block


func _on_GrabBlockArea_body_exited(body):
	if body == grabbable_block:
		grabbable_block = null