extends RigidBody2D

@export var speed: float = 200
@export var force_threshold: float = 300.0  # Max force to stay attached
@export var tilemap: TileMap
@export var seat_offset := Vector2(100, 0)

@onready var camera = %Camera2D
@onready var ship = %Ship

var direction := Vector2.ZERO
var angle_input := 0.0

var seated := false
var on_ground := false
var jetpack := false
var linear_dampener := true
var angular_dampener := true
var relative_pos = Vector2(100,0)

var previous_velocity := Vector2.ZERO
var current_ship: RigidBody2D = null

signal ship_control(direction: Vector2, angle: float, angular_damp: bool, linear_damp: bool)

func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	get_inputs()

	if seated:
		handle_seated()
	else:
		global_rotation = (get_global_mouse_position()-global_position).normalized().angle()
		detect_ship()
		if on_ground:
			apply_ship_locking_logic(delta)

	previous_velocity = linear_velocity


func get_inputs():
	direction = Input.get_vector("player_left", "player_right", "player_forward", "player_backward")
	angle_input = Input.get_axis("rcs_ccw", "rcs_cw")
	if Input.is_action_pressed("sprint"):
		speed = 300
	else:
		speed = 200
	if Input.is_action_just_pressed("angular_dampener"):
		angular_dampener = !angular_dampener
	if Input.is_action_just_pressed("linear_dampener"):
		linear_dampener = !linear_dampener
	if Input.is_action_just_pressed("exit_seat"):
		seated = !seated


func handle_seated():
	rotation = deg_to_rad(-90)
	position = seat_offset.rotated(ship.rotation) + ship.position
	if current_ship:
		linear_velocity = current_ship.linear_velocity
	ship_control.emit(direction, angle_input, angular_dampener, linear_dampener)


func detect_ship():
	# TEMP: Always assume the player is on the ship floor.
	on_ground = true
	current_ship = ship  # Or manually assign the ship node TODO



func is_standing_on_valid_tile() -> bool:
	
	if not tilemap:
		return false
	var local_pos = tilemap.to_local(global_position)
	var tile_pos = tilemap.local_to_map(local_pos)
	var tile_data = tilemap.get_cell_tile_data(0, tile_pos)
	return tile_data != null and tile_data.get_custom_data("walkable") == true


func apply_ship_locking_logic(delta: float):
	if not current_ship:
		return
	
	if direction == Vector2.ZERO:
		# No movement input: lock player exactly on ship floor
		
		# Calculate global position of relative_pos in ship space
		var expected_pos = current_ship.global_position + relative_pos.rotated(current_ship.rotation)
		global_position = expected_pos
		
		# Calculate tangential velocity due to rotation: ω × r = angular_velocity * perpendicular vector
		var tangential_vel = Vector2(-relative_pos.y, relative_pos.x) * current_ship.angular_velocity
		var expected_velocity = current_ship.linear_velocity + tangential_vel
		
		linear_velocity = expected_velocity
		angular_velocity = current_ship.angular_velocity
		
	else:
		# Movement input: move relative_pos in ship local space, then update position & velocity
		
		# Calculate movement delta in ship local space (no rotation)
		var local_move = direction.normalized() * speed * delta
		if not camera.rotate:
			local_move = local_move.rotated(-current_ship.rotation)
		relative_pos += local_move  # Add directly in ship local coords
		
		# Update global position from relative_pos
		var expected_pos = current_ship.global_position + relative_pos.rotated(current_ship.rotation)
		global_position = expected_pos
		
		# Calculate velocity due to rotation (centripetal effect)
		var tangential_vel = Vector2(-relative_pos.y, relative_pos.x) * current_ship.angular_velocity
		var expected_velocity = current_ship.linear_velocity + tangential_vel
		
		# Add player movement velocity converted to global coords
		var move_velocity = local_move / delta  # movement velocity in ship local space
		linear_velocity = expected_velocity + move_velocity.rotated(current_ship.rotation)
		angular_velocity = current_ship.angular_velocity













#extends RigidBody2D
#@onready var ship = %Ship
#@onready var camera = %Camera2D
#var seated = 0
#var speed = 200
#var relative_pos = Vector2(100,0)
#var direction = Vector2(0,0)
#var angle = 0
#var linear_dampen = 1
#var angular_dampen = 1
#var on_ground = 1
#var jetpack = 0
#var previous_velocity = Vector2(0,0)
#signal shipControl(direction: Vector2,angle: float, angular_dampen: int, linear_dampen: int)
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _physics_process(delta: float) -> void:
	## GET INPUTS
	#direction = Input.get_vector("player_left","player_right","player_forward","player_backward")
	#angle = Input.get_axis("rcs_ccw","rcs_cw")
	#if Input.is_action_just_pressed("angular_dampener"):
		#angular_dampen = abs(angular_dampen - 1)
	#if Input.is_action_just_pressed("linear_dampener"):
		#linear_dampen = abs(linear_dampen - 1)
	#if Input.is_action_just_pressed("exit_seat"):
		#seated = abs(seated - 1)
		#if seated: # just sat
			#pass
		#else: # just stood
			#pass
	#var offset = global_position - ship.global_position
	#var desired_velocity = ship.angular_velocity * Vector2(-offset.y,offset.x) + ship.linear_velocity
	#apply_central_impulse((desired_velocity-linear_velocity)*mass)
	#var acceleration = (linear_velocity - previous_velocity)
	#
	#print(position)
	#print("				")
	#print(linear_velocity)
	#if seated:
		#rotation = deg_to_rad(-90)
		#position = relative_pos
		#linear_velocity = ship.linear_velocity
		#shipControl.emit(direction,angle,angular_dampen,linear_dampen)
	#elif on_ground:
		#global_rotation = (get_global_mouse_position()-global_position).normalized().angle()
		#if direction!= Vector2.ZERO:
			#if camera.rotate:
				#linear_velocity += direction.rotated(ship.rotation) * speed
			#else:
				#var input_force = direction.normalized() * speed * delta * mass
				#apply_central_force(input_force.rotated(ship.rotation))
			##position += direction * delta * 100
			##apply_force(direction * delta * speed*1000)
		#else:
			#pass
	#else:
		#pass
		#
	#previous_velocity = linear_velocity
