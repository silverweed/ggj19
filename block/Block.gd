extends KinematicBody2D

signal thrown(self_block)

onready var vert_collider = $Colliders/VertCollider
onready var horiz_collider = $Colliders/HorizCollider
onready var size = $CollisionShape2D.shape.extents

const COLLIDER_SIZE = 50

## For Verlet integration
var prev_position = Vector2()
var cur_velocity = Vector2()
var throw_time = 0

var timer : Timer

func _ready():
	var r = randi() % 16
	match r:
		0: $Sprite.texture = load("res://block/sprites/block_angry_eyes_animation.png")
		1: $Sprite.texture = load("res://block/sprites/block_annoyed_eyes_animation.png")
		2: $Sprite.texture = load("res://block/sprites/block_dummy_eyes_animation.png")
	
	if r < 3:
		timer = Timer.new()
		timer.wait_time = rand_range(0, 10)
		timer.connect("timeout", self, "animate")
		timer.start()
		add_child(timer)
	
	
func throw(initial_velocity : Vector2):
	prev_position = position
	cur_velocity = initial_velocity
	throw_time = 0;

	emit_signal("thrown", self)
	
func _draw():
	var center = Vector2(- size.y + 10, - size.y) +\
				 Vector2( 0, size.y - 10)
	var shift = Vector2(+ size.y - 10, 0)
	var intensity = Vector2 ( 0, 100);
	
	draw_line( center, center + intensity, Color.red)
	center += 2 * shift
	
	draw_line( center, center + intensity, Color.red)

	

func experimental_collision() -> bool:
	var space_rid = get_world_2d().space
	var space_state = Physics2DServer.space_get_direct_state(space_rid)
	# use global coordinates, not local to node
	
	var center = global_position + Vector2(0.5 * size.x - 0.1, 0) * sign(cur_velocity.x)
	var shift = Vector2( 0 , - size.x / 2)
	var intensity = Vector2 ( 0 , cur_velocity.x + 0.1);
	
	var result0 = space_state.intersect_ray(center, center + intensity , [self])
	center += shift;
	var result1 = space_state.intersect_ray(center, center + intensity, [self])
	center += shift;
	var result2 = space_state.intersect_ray(center, center + intensity, [self])
	
	if(!result1.empty()):
		var p = result1.position
		var sgn = -1 if p.x > global_position.x else 1
		global_position.x = p.x + sgn * size.x
		return true
	
	
	return false
	
	
func can_be_grabbed() -> bool:
	for area in vert_collider.get_overlapping_areas():
		var other = area.get_parent().get_parent()
		if other.is_in_group("blocks") and other.global_position.y < global_position.y:
			return false
	return true

func set_collider_disabled(is_disabled):
	vert_collider.get_node("CollisionShape2D").disabled = is_disabled
	horiz_collider.get_node("CollisionShape2D").disabled = is_disabled
	$CollisionShape2D.disabled = is_disabled
	
	
func animate():
	$AnimationPlayer.play("idle")
	timer.wait_time = 5 + rand_range(0, 10)