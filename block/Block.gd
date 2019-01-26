extends KinematicBody2D

signal thrown(self_block)

onready var vert_collider = $Colliders/VertCollider
onready var horiz_collider = $Colliders/HorizCollider
onready var size = $CollisionShape2D.shape.extents

## For Verlet integration
var prev_position = Vector2()
var cur_velocity = Vector2()


func throw(initial_velocity : Vector2):
	prev_position = position
	cur_velocity = initial_velocity

	emit_signal("thrown", self)
	
	
func can_be_grabbed() -> bool:
	for area in vert_collider.get_overlapping_areas():
		var other = area.get_parent().get_parent()
		if other.is_in_group("blocks") and other.global_position.y < global_position.y:
			return false
	return true
