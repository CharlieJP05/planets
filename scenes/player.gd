extends RigidBody2D

@export var move_speed: float = 150.0
@onready var ship = %Ship
@onready var feet_shape = $Feet
@export var camera: Camera2D


var grounded = true
var jetpack = false
var mag_boots = true
var fall = false
var start_pause = true # TODO proper fix this

func _physics_process(delta: float) -> void:
	var direction = Input.get_vector("player_right","player_left","player_backward","player_forward")
	if Input.is_action_just_pressed("jetpack"):
		jetpack = !jetpack
	if Input.is_action_just_pressed("mag_boots"):
		mag_boots = !mag_boots
	# Toggle grounded / floating state
	if not fall and !start_pause:
		fall = is_fall()
	if (not mag_boots and grounded) or (fall and grounded) or (mag_boots and not grounded):
		fall = false
		if grounded:
			linear_velocity = 	(ship.angular_velocity * 
								(ship.global_position-global_position)).rotated(deg_to_rad(-90)) - direction*move_speed
			grounded = false
			reparent($"..")
			freeze = false
			ship = null
			print("Floating")
		else:
			# Reattach to ship (make sure you assign the ship node here)
			if not is_fall():
				ship = %Ship # or your ship node path
				reparent(ship)
				freeze = true
				grounded = true
				print("Grounded on ship")


	if grounded:
		direction = direction.rotated(camera.rotation-deg_to_rad(180))
		move_and_collide(direction*move_speed*delta) # TODO add own collisions
		
	else:
		# Floating in space - normal rigidbody physics
		print(jetpack)
		if jetpack:
			var space_input = direction * move_speed / 20
			linear_velocity -= space_input
	
	
	# to fix first loop issues
	start_pause = false
	

func is_fall() -> bool:
	var space_state = get_world_2d().direct_space_state
	
	var params = PhysicsShapeQueryParameters2D.new()
	params.shape = feet_shape.shape
	params.transform = feet_shape.global_transform
	params.collision_mask = 1 << 0  # Layer 1 = bit 0
	params.collide_with_bodies = true
	params.collide_with_areas = true

	var results = space_state.intersect_shape(params, 8)
	if results == []:
		return true
	return false
