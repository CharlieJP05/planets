extends RigidBody2D

var speed = 500
var damp = 1
var Aspeed = 5
var Adamp = 1 # smaller stronger
var threashold = 0.05
#control vars
var angular_dampen = 1
var linear_dampen = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	#position = Vector2(100,500)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#get inputs
	var direction = Input.get_vector("rcs_left","rcs_right","rcs_forward","rcs_backward")
	var angle = Input.get_axis("rcs_ccw","rcs_cw")
	direction = direction.rotated(rotation)
	if Input.is_action_just_pressed("angular_dampener"):
		angular_dampen = abs(angular_dampen - 1)
	if Input.is_action_just_pressed("linear_dampener"):
		linear_dampen = abs(linear_dampen - 1)
	
	#control logic
	if angular_dampen:
		if -threashold <= angular_velocity and angular_velocity <= threashold:
			angular_velocity = 0
		angular_velocity -= angular_velocity/Adamp * delta
	if linear_dampen:
		if -threashold <= linear_velocity.x and linear_velocity.x <= threashold:
			linear_velocity.x = 0
		if -threashold <= linear_velocity.y and linear_velocity.y <= threashold:
			linear_velocity.y = 0
		linear_velocity -= linear_velocity/damp * delta
	linear_velocity += direction * speed * delta
	angular_velocity += angle * Aspeed * delta
	
	#update globals
