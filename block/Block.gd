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

func throw(initial_velocity : Vector2):
	prev_position = position
	cur_velocity = initial_velocity
	throw_time = 0;

	emit_signal("thrown", self)
	
	
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