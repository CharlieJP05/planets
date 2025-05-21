extends Camera2D
@onready var ship = %Ship
var rotate = 0

var shift = Vector2(0, 0)

func _ready():
	make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("camera_rotate"):
		rotate = abs(rotate - 1)
	if rotate:
		rotation = ship.rotation
	else:
		rotation = 0
	position = ship.position + shift
