extends KinematicBody2D

signal thrown(self_block)

onready var vert_collider = $Colliders/VertCollider/CollisionShape2D

## For Verlet integration
var prev_position = Vector2()
var cur_velocity = Vector2()


func throw(initial_velocity : Vector2):
	prev_position = position
	cur_velocity = initial_velocity

	emit_signal("thrown", self)