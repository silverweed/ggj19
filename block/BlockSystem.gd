extends CanvasItem

signal blocks_collided(direction, position)
signal block_destroyed(position)

onready var block_prefab = preload("res://block/Block.tscn")
const Block = preload("res://block/Block.gd")
const Player = preload("res://player/Player.gd")

export var floor_y = 0

# pyhsics parameters
var gravity = Vector2(0, 35000)
var transient = 1
var damping = 0.9

# collision
var skinwidth = 30

# blocks
var sleeping_blocks = []
var travelling_blocks = []

var removed_blocks = []
var activation_timer = 0

# collision layers
var block_cl = Block.get_exclusive_collision_layer()
var player_cl = Player.get_exclusive_collision_layer()

export var block_n : int
export var area : int
export var spawn_offset : float

var blocks_left = 100

func _ready ():
	blocks_left = block_n
	
	while blocks_left > 0:
		var b = block_prefab.instance()
		add_child(b)
		b.global_position = Vector2(spawn_offset + 122 * ( randi() % area), -2000 - 200 * (blocks_left))
		blocks_left = blocks_left - 1
	
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
		
		# sanity checks
		awake(block)
		
		if (check_inner(block, 40)):
			emit_signal("block_destroyed", block.global_position)
			block.global_position = Vector2(spawn_offset + 122 * ( randi() % area), -2000 - 5000)
			block.cur_velocity = Vector2()
			continue
			
		var delta_pos = new_position - block.position; 

		block.position.x += delta_pos.x
		
		if collision_x(block, delta_pos.x): #block_colliding_horizontally(block):
			block.cur_velocity.x = 0

		block.position.y += delta_pos.y
		if collision_y(block, delta_pos.y):
			set_block_as_sleeping(block)
			
		
func collision_x(block: Block, delta : float) -> bool:
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

	
func collision_y(block: Block, delta : float) -> bool:
	# use global coordinates, not local to node
	var center = block.global_position + Vector2(- block.size.y + skinwidth, 0) +\
				 Vector2( 0, block.size.y - skinwidth) * sign(delta)
	var shift = Vector2(+ block.size.y - skinwidth, 0)
	
	if try_cast(delta, center, block, false):
		return delta >= 0
		
	if try_cast(delta, center + shift, block, false):
		return delta >= 0
		
	if try_cast(delta, center + 2 * shift, block, false):
		return delta >= 0

	return false


func check_inner(block: Block, area: float ) -> bool:
	# use global coordinates, not local to node
	var center = block.global_position;
	var shift_1 = Vector2( area, 0)
	var shift_2 = Vector2( 0, area)
	
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	
	var result = space_state.intersect_ray(center + shift_1, center - shift_1, [block], block_cl)
	if !result.empty():
		return true
		
	result = space_state.intersect_ray(center + shift_2, center - shift_2, [block], block_cl)
	if !result.empty():
		return true
		
	return false
	
func try_cast(delta : float, center : Vector2, block : Block, horiz : bool) -> bool:
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	var intensity = Vector2(delta + skinwidth, 0) if horiz else Vector2(0, delta + skinwidth)
	
	var player_result = space_state.intersect_ray(center, center + intensity, [block], player_cl)
	if !player_result.empty():
		player_result.collider.try_kill(block)
		
	
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
		emit_signal("blocks_collided", Vector2(1, 0), block.global_position)
		return true
	return false


func check_cast_y(result : Dictionary, block : Block) -> bool:
	if !result.empty():
		var p = result.position
		var sgn = -1 if p.y > block.global_position.y else 1
		block.global_position.y = p.y + sgn * block.size.y
		emit_signal("blocks_collided", Vector2(0, 1), block.global_position)
		return true
		
	return false


func register_all_blocks():
	for block in get_tree().get_nodes_in_group("blocks"):
		add_block(block)
	print("registered ", sleeping_blocks.size(), " sleeping blocks and ",
		travelling_blocks.size(), " travelling blocks")


func add_block(block : Block):
	sleeping_blocks.append(block)
	block.connect("thrown", self, "set_block_as_travelling")
	if block.position.y < floor_y:
		set_block_as_travelling(block)


func set_block_as_travelling(block : Block):
	assert(block in sleeping_blocks)
	# TODO handle restart
	assert(!(block in travelling_blocks))
	
	sleeping_blocks.erase(block)
	travelling_blocks.append(block)
	
	
func set_block_as_sleeping(block : Block):
	assert(block in travelling_blocks)
	assert(!(block in sleeping_blocks))
	
	var center = block.global_position;
	var shift = Vector2( 0, block.size.y + 10)
	
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	
	var result = space_state.intersect_ray(center, center + shift, [block], block_cl)
	if result.empty():
		emit_signal("block_destroyed", block.global_position)
		block.global_position = Vector2(spawn_offset + 122 * ( randi() % area), -2000 - 5000)
		block.cur_velocity = Vector2()
	else:
		travelling_blocks.erase(block)
		sleeping_blocks.append(block)

func awake(block: Block):
	for area in block.vert_collider.get_overlapping_areas():
		var other = area.get_parent().get_parent()
		if other.is_in_group("blocks") and other.global_position.y < block.global_position.y:
			if is_sleeping(other):
				other.cur_velocity = Vector2(0, 10)
				other.throw_time = 0
				set_block_as_travelling(other)
	

func is_sleeping(block : Block) -> bool:
	return block in sleeping_blocks