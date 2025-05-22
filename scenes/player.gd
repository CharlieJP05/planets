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
	
	# Calculate the global position the player "should" be at on the ship,
	# based on the target relative position in ship-local coordinates
	var target_global_pos = current_ship.global_position + relative_pos.rotated(current_ship.rotation)
	
	# SPRING FORCE to pull player toward target position
	var displacement = target_global_pos - global_position
	var spring_stiffness = 1500.0  # tune this: higher = stronger pull
	var spring_force = displacement * spring_stiffness
	
	# FRICTION FORCE opposing player velocity to prevent slipping
	var friction_coefficient = 10  # tune this: higher = more friction
	var friction_force = -linear_velocity * friction_coefficient
	
	# Apply these forces
	apply_central_force(spring_force)
	apply_central_force(friction_force)
	
	# Handle player input movement by moving the target position on the ship surface
	if direction != Vector2.ZERO:
		# Move relative_pos by input scaled by speed and delta time
		var move_delta = direction.normalized() * speed * delta
		
		# If your camera rotates the player movement, adjust here:
		if not camera.rotate:
			# Convert move_delta to ship local coordinates (un-rotate by ship rotation)
			move_delta = move_delta.rotated(-current_ship.rotation)
		
		relative_pos += move_delta















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
