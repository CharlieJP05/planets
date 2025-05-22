extends CharacterBody2D

@export var speed := 200.0
@export var mass := 1.0

@onready var current_ship: RigidBody2D = %Ship
var relative_pos := Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Face mouse at start
	global_rotation = (get_global_mouse_position() - global_position).angle()

	var direction := Input.get_vector("player_left", "player_right", "player_forward", "player_backward")

	if not current_ship:
		return

	if direction == Vector2.ZERO:
		# No movement: lock player position exactly on ship, zero velocity
		var expected_pos = current_ship.global_position + relative_pos.rotated(current_ship.rotation)
		global_position = expected_pos

		velocity = Vector2.ZERO

	else:
		# Movement input: move relative_pos in ship local space
		var local_move = direction.normalized() * speed * delta

		# Rotate local_move from global input space to ship local space by negative ship rotation
		local_move = local_move.rotated(-current_ship.rotation)

		relative_pos += local_move

		# Update global position from relative_pos and ship position
		var expected_pos = current_ship.global_position + relative_pos.rotated(current_ship.rotation)

		# Calculate tangential velocity (rotation effect)
		var tangential_vel = Vector2(-relative_pos.y, relative_pos.x) * current_ship.angular_velocity

		# Ship linear velocity + tangential velocity gives base velocity
		var base_velocity = current_ship.linear_velocity + tangential_vel

		# Player movement velocity in global space
		var move_velocity = local_move / delta
		velocity = base_velocity + move_velocity.rotated(current_ship.rotation)

		# Assign velocity and move
		self.velocity = velocity
		move_and_slide()

		# Update relative_pos after move to sync position
		var offset = global_position - current_ship.global_position
		relative_pos = offset.rotated(-current_ship.rotation)

	# Calculate centripetal force for debug
	var radius = relative_pos.length()
	var omega = current_ship.angular_velocity
	var mass = self.mass  # make sure your player node has mass property, or define mass as a var

	var centripetal_force = mass * omega * omega * radius
	print("Centripetal Force: ", centripetal_force)
