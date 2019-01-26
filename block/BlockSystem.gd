extends Node

const Block = preload("res://block/Block.gd")

const SNAP_HORIZONTALLY = 1
const SNAP_VERTICALLY = 1 << 1

export var floor_y = 0

var gravity = Vector2(0, 1000)

var sleeping_blocks = []
var travelling_blocks = []

func _ready():
	call_deferred("register_all_blocks")


func _physics_process(delta):
	for block in travelling_blocks:
		var new_position =  block.position + \
							block.cur_velocity * delta + \
							0.5 * gravity * delta * delta
		var new_velocity = block.cur_velocity + gravity * delta
		
		block.position = new_position
		block.cur_velocity = new_velocity
		
		if must_freeze_block(block):
			set_block_as_sleeping(block)
			continue
		
		if block_colliding_horizontally(block):
			block.cur_velocity.x = 0


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
	#block.vert_collider.disabled = false
	
	
func set_block_as_sleeping(block : Block):
	assert(block in travelling_blocks)
	assert(!(block in sleeping_blocks))
	
	travelling_blocks.erase(block)
	sleeping_blocks.append(block)
	#block.vert_collider.disabled = true
	
	
func must_freeze_block(block : Block) -> bool:
	for area in block.vert_collider.get_overlapping_areas():
		var other = area.get_parent().get_parent()
		if !(other is Block):
			continue
			
		if other == block:
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