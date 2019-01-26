extends RigidBody2D

signal thrown(self_block)

## For Verlet integration
var prev_position = Vector2()

func throw(impulse : Vector2):
	apply_central_impulse(impulse)
	

func _integrate_forces(state):
	var delta = state.step
	var gravity = state.total_gravity
	var new_position = 2 * position - prev_position + state.linear_velocity * delta + 0.5 * gravity * delta * delta
	var new_velocity = state.linear_velocity + gravity * delta
	var pos_delta = new_position - position
	
	prev_position = position
	state.transform.translated(pos_delta)
	state.linear_velocity = new_velocity