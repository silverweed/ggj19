extends CanvasItem

signal blocks_collided(direction)

const Block = preload("res://block/Block.gd")
const Player = preload("res://player/Player.gd")

export var floor_y = 0

var gravity = Vector2(0, 25000)
var transient = 1
var damping = 0.8

var skinwidth = 20

var sleeping_blocks = []
var travelling_blocks = []


var block_cl = Block.get_exclusive_collision_layer()

func _ready():
	call_deferred("register_all_blocks")


func _physics_process(delta):
	

	for block in travelling_blocks:
		
		# interpolator to transition from the low friction area to the hig friction one
		var interpolant = min(block.throw_time/transient, 1)
		
		var new_position =  block.position + \
							block.cur_velocity * delta + \
							0.5 * gravity * delta * delta
		var new_velocity = block.cur_velocity + Vector2 (0, lerp(0, gravity.y, interpolant) * delta)
		new_velocity *= lerp(1, damping, interpolant)
		
		block.throw_time += delta
		block.cur_velocity = new_velocity
		
		var delta_pos = new_position - block.position; 

		block.position.x += delta_pos.x
		
		if experimental_collision(block, delta_pos.x): #block_colliding_horizontally(block):
			block.cur_velocity.x = 0

		block.position.y += delta_pos.y
		if experimental_collision_v(block, delta_pos.y):
			set_block_as_sleeping(block)
		
func experimental_collision(block: Block, delta : float) -> bool:
	# use global coordinates, not local to node
	var center = block.global_position + Vector2(0, - skinwidth + block.size.x) +\
				 Vector2( block.size.x - skinwidth, 0) * sign(block.cur_velocity.x)
	var shift = Vector2( 0 , - block.size.x + skinwidth)

	if try_cast(delta, center, block, true):
		return true
		
	if try_cast(delta, center + shift, block, true):
		return true
		
	if try_cast(delta, center + 2 * shift, block, true):
		return true
	
	return false

	
func experimental_collision_v(block: Block, delta : float) -> bool:
	# use global coordinates, not local to node
	var center = block.global_position + Vector2(- block.size.y + skinwidth, 0) +\
				 Vector2( 0, block.size.y - skinwidth) * sign(delta)
	var shift = Vector2(+ block.size.y - skinwidth, 0)
	
	if try_cast(delta, center, block, false):
		return true
		
	if try_cast(delta, center + shift, block, false):
		return true
		
	if try_cast(delta, center + 2 * shift, block, false):
		return true

	return false
	
	
func try_cast(delta : float, center : Vector2, block : Block, horiz : bool) -> bool:
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	var intensity = Vector2(delta + skinwidth, 0) if horiz else Vector2(0, delta + skinwidth)
	
	var result = space_state.intersect_ray(center, center + intensity, [block], block_cl)
	if horiz:
		return check_cast_x(result, block) 
	else:
		return check_cast_y(result, block)
		
	
func check_cast_x(result : Dictionary, block : Block) -> bool:
	if !result.empty():
		var p = result.position
		var sgn = -1 if p.x > block.global_position.x else 1
		block.global_position.x = p.x + sgn * block.size.x
		emit_signal("blocks_collided", Vector2(1, 0))
		return true
		
	return false
	

func check_cast_y(result : Dictionary, block : Block) -> bool:
	if !result.empty():
		var p = result.position
		var sgn = -1 if p.y > block.global_position.y else 1
		block.global_position.y = p.y + sgn * block.size.y
		emit_signal("blocks_collided", Vector2(0, 1))
		return true
		
	return false


func register_all_blocks():
	for block in get_tree().get_nodes_in_group("blocks"):
		sleeping_blocks.append(block)
		block.connect("thrown", self, "set_block_as_travelling")
		if block.position.y < floor_y:
			set_block_as_travelling(block)
	print("registered ", sleeping_blocks.size(), " sleeping blocks and ",
		travelling_blocks.size(), " travelling blocks")
		
		
func set_block_as_travelling(block : Block):
	assert(block in sleeping_blocks)
	# TODO handle restart
	assert(!(block in travelling_blocks))
	
	sleeping_blocks.erase(block)
	travelling_blocks.append(block)
	
	
func set_block_as_sleeping(block : Block):
	assert(block in travelling_blocks)
	assert(!(block in sleeping_blocks))
	
	travelling_blocks.erase(block)
	sleeping_blocks.append(block)
	
	

func is_sleeping(block : Block) -> bool:
	return block in sleeping_blocks