extends Camera2D
@onready var ship = %Ship
var rotate = 0
var zoom_step = 1.1

var shift = Vector2(0, 0)

func _ready():
	zoom = scale
	make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("zoom_in"):
		zoom *= zoom_step
		scale /= zoom_step
	elif Input.is_action_just_pressed("zoom_out"):
		zoom /= zoom_step
		scale *= zoom_step
	if Input.is_action_just_pressed("camera_rotate"):
		rotate = abs(rotate - 1)
	if rotate:
		rotation = ship.rotation
	else:
		rotation = 0
	position = ship.position + shift
