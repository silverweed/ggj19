extends CanvasItem

const Block = preload("res://block/Block.gd")
signal blocks_collided

const SNAP_HORIZONTALLY = 1
const SNAP_VERTICALLY = 1 << 1

export var floor_y = 0

var gravity = Vector2(0, 25000)
var transient = 1
var damping = 0.8

var skinwidth = 20

var sleeping_blocks = []
var travelling_blocks = []

var players = []

func _ready():
	call_deferred("register_all_blocks")
	players = get_tree().get_nodes_in_group("players")


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
		
func experimental_collision(block: Block, delta) -> bool:
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	
	var ignore = players.duplicate()
	ignore.append(block)
	# use global coordinates, not local to node
	
	var center = block.global_position + Vector2(0, - skinwidth + block.size.x) +\
				 Vector2( block.size.x - skinwidth, 0) * sign(block.cur_velocity.x)
	var shift = Vector2( 0 , - block.size.x + skinwidth)
	var intensity = Vector2 ( delta + skinwidth, 0);
	
	var result = space_state.intersect_ray(center, center + intensity ,ignore)
	if(!result.empty()):
		var p = result.position
		var sgn = -1 if p.x > block.global_position.x else 1
		block.global_position.x = p.x + sgn * block.size.x
		return true
		
	center += shift
	result = space_state.intersect_ray(center, center + intensity, ignore)
	if(!result.empty()):
		var p = result.position
		var sgn = -1 if p.x > block.global_position.x else 1
		block.global_position.x = p.x + sgn * block.size.x
		return true
		
	center += shift
	result = space_state.intersect_ray(center, center + intensity, ignore)
	if(!result.empty()):
		var p = result.position
		var sgn = -1 if p.x > block.global_position.x else 1
		block.global_position.x = p.x + sgn * block.size.x
		return true
	return false
	
func experimental_collision_v(block: Block, delta) -> bool:
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	# use global coordinates, not local to node
	
	var ignore = players.duplicate()
	ignore.append(block)
	
	var center = block.global_position + Vector2(- block.size.y + skinwidth, 0) +\
				 Vector2( 0, block.size.y - skinwidth) * sign(delta)
	var shift = Vector2(+ block.size.y - skinwidth, 0)
	var intensity = Vector2 (0, delta + skinwidth);
	
	var result = space_state.intersect_ray(center, center + intensity , players)
	if(!result.empty()):
		var p = result.position
		var sgn = -1 if p.y > block.global_position.y else 1
		block.global_position.y = p.y + sgn * block.size.y
		return true
		
	center += shift
	result = space_state.intersect_ray(center, center + intensity, players)
	if(!result.empty()):
		var p = result.position
		var sgn = -1 if p.y > block.global_position.y else 1
		block.global_position.y = p.y + sgn * block.size.y
		return true
		
	center += shift
	result = space_state.intersect_ray(center, center + intensity, players)
	if(!result.empty()):
		var p = result.position
		var sgn = -1 if p.y > block.global_position.y else 1
		block.global_position.y = p.y + sgn * block.size.y
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
	
	
func must_freeze_block(block : Block) -> bool:
	for body in block.vert_collider.get_overlapping_bodies():
		if body.is_in_group("ground"):
			return true
	
	for area in block.vert_collider.get_overlapping_areas():
		var other = area.get_parent().get_parent()
		if !(other is Block):
			continue
			
		if other.position.y < block.position.y:
			continue
			
		if !(other in sleeping_blocks):
			continue
			
		var diff = other.global_position - block.global_position
		if block.cur_velocity.dot(diff) > 0:
			snap_block_to_block(block, other, SNAP_VERTICALLY)
			return true
	
	return false  
	


func block_colliding_horizontally(block : Block) -> bool:
	for area in block.horiz_collider.get_overlapping_areas():
		var other = area.get_parent().get_parent()
		if !(other is Block):
			continue
			
		if other == block:
			continue
		
		snap_block_to_block(block, other, SNAP_HORIZONTALLY)
		return true
		
	return false
	
	
func snap_block_to_block(to_snap : Block, pivot : Block, snap_mode : int):
	if snap_mode & SNAP_VERTICALLY:
		var sgn = -1 if pivot.global_position.y > to_snap.global_position.y else 1
		to_snap.global_position.y = pivot.global_position.y + sgn * 2 * pivot.size.y

	if snap_mode & SNAP_HORIZONTALLY:
		var sgn = -1 if pivot.global_position.x > to_snap.global_position.x else 1
		to_snap.global_position.x = pivot.global_position.x + sgn * 2 * pivot.size.x
		
		
func is_sleeping(block : Block) -> bool:
	return block in sleeping_blocks