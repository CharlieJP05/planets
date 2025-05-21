extends RigidBody2D
@onready var ship = %Ship
var seated = 0
var speed = 10000
var seatPos = Vector2(0,0)
var direction = Vector2(0,0)
var angle = 0
var linear_dampen = 1
var angular_dampen = 1
var on_ground = 1
var jetpack = 0
signal shipControl(direction: Vector2,angle: float, angular_dampen: int, linear_dampen: int)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# GET INPUTS
	if seated:
		direction = Input.get_vector("rcs_left","rcs_right","rcs_forward","rcs_backward")
	else:
		direction = Input.get_vector("player_left","player_right","player_forward","player_backward")
	angle = Input.get_axis("rcs_ccw","rcs_cw")
	if Input.is_action_just_pressed("angular_dampener"):
		angular_dampen = abs(angular_dampen - 1)
	if Input.is_action_just_pressed("linear_dampener"):
		linear_dampen = abs(linear_dampen - 1)
	if Input.is_action_just_pressed("exit_seat"):
		seated = abs(seated - 1)
		if seated: # just sat
			pass
		else: # just stood
			pass
			
	print(direction)
	if seated:
		rotation = deg_to_rad(-90)
		position = seatPos
		shipControl.emit(direction,angle,angular_dampen,linear_dampen)
	elif on_ground:
		global_rotation = (get_global_mouse_position()-global_position).normalized().angle()
		if direction!= Vector2.ZERO:
			linear_velocity = direction * delta * speed #ship.linear_velocity + direction * delta * speed
		else:
			linear_velocity = ship.linear_velocity
	else:
		pass
		
