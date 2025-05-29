extends RigidBody2D

@export var move_speed: float = 150.0
@onready var ship = null
var tile_map = null
@onready var feet_shape = $Feet
@export var camera: Camera2D
var cam_rotation = 0

signal shipControl(direction: Vector2,angle: float, angular_dampen: bool, linear_dampen: bool)
signal place()
var angle = 0
var direction = Vector2.ZERO
var hotbar = ["wall","thruster1","thruster2","thruster3","floor","seat","tank","pipe","mars","satalite"]
var hotbar_pos = 0
var building = false
var removing = false
var grounded = true
var sitting = false
var jetpack = false
var mag_boots = true
var fall = false
var start_pause = true # TODO proper fix this

func _ready() -> void:
	ship = get_parent().get_node("Ship")
	tile_map = ship.get_node("TileMap")
func _physics_process(delta: float) -> void:
	global_rotation = (get_global_mouse_position()-global_position).normalized().angle()
	#direction = Vector2(0,0)
	angle = 0
	if 0:
		jetpack = !jetpack
		
	if 0:
		mag_boots = !mag_boots
	if 0:
		if !mag_boots: # temporary sit function
			mag_boots
		sitting = !sitting
	if 0:
		if sitting:
			%Ship.angular_dampen = !%Ship.angular_dampen
	if 0:
		if sitting:
			%Ship.linear_dampen = !%Ship.linear_dampen
	if 0:
		building = !building
	if 0:
		removing = !removing
	if 0:
		hotbar_pos = (hotbar_pos + 1) % 10
	if 0:
		hotbar_pos = (hotbar_pos + 9) % 10
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
				tile_map = %Ship.get_node("TileMap")
				reparent(ship)
				freeze = true
				grounded = true
				print("Grounded on ship")
				
				
				
	direction = direction.rotated(cam_rotation-deg_to_rad(180))
	if building:
		if Input.is_action_just_pressed("rotate"):
			tile_map.place_rot = (tile_map.place_rot + 90) % 360
		tile_map.hover_cell(Vector2(hotbar_pos,0))
		if Input.is_action_pressed("place"):
			if !removing:
				tile_map.create(Vector2(hotbar_pos,0))
			else:
				tile_map.destroy()
	if sitting:
		shipControl.emit(direction,angle)
		rotation = 0
	elif grounded:
		# TODO add own collisions
		#move_and_collide(direction*move_speed*delta) # sticks
		move_and_slide_manual(direction*move_speed*delta) # broke
		#linear_velocity += direction*move_speed/20 # doesnt work if frozen
		
		
	elif not sitting:
		# Floating in space - normal rigidbody physics
		if jetpack:
			var space_input = direction * move_speed / 20
			linear_velocity += space_input
	else:
		pass
		
	
	
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

func move_and_slide_manual(velocity: Vector2) -> void:
	if velocity == Vector2.ZERO:
		return

	var collision = move_and_collide(velocity)

	if collision:
		var normal = collision.get_normal()
		var slide_vector = velocity - normal * velocity.dot(normal)
		move_and_collide(slide_vector)
