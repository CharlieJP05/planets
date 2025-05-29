extends Camera2D
var rotate = false
var zoom_step = 1.1
var player
var shift = Vector2(0, 0)
var follow

func _ready():
	zoom = scale
	make_current()

func add_player():
	player = get_parent().get_node("Player")
	get_node("HUD").add(player)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player == null:
		return
	if player.grounded and player.ship != null:
		follow = player.ship
	else:
		follow = player
	if Input.is_action_just_pressed("zoom_in") and zoom.x < 10:
		zoom *= zoom_step
		scale /= zoom_step
	elif Input.is_action_just_pressed("zoom_out") and zoom.x > 0.1:
		zoom /= zoom_step
		scale *= zoom_step
	if Input.is_action_just_pressed("camera_rotate"):
		rotate = !rotate
	if rotate:
		rotation = follow.rotation
	else:
		rotation = 0
	if zoom.x > 1:
		global_position = player.global_position
	else:
		global_position = follow.global_position + shift
