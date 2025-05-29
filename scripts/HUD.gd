extends Control
#@onready var player = get_node("../Player")
@onready var ship = %Ship
@onready var player = %Player
@onready var camera = %Camera2D

var offset = Vector2(0, 0)
func add(p):
	player = p 
func _process(delta):
	if player != null:
		if player.ship != null:
			ship = player.ship
	if ship != null:
		$Values/Velocity/linear.text = String("%.2f" % ship.linear_velocity.length())
		$Values/Velocity/angular.text = String("%.2f" % ship.angular_velocity)
	
		$Values/Position/linear.text = String("%.2f" % ship.position.length())
		$Values/Position/angular.text = String("%.2f" % ship.rotation)
	
		$Values/Dampeners/linear.text = str(ship.linear_dampen)
		$Values/Dampeners/angular.text = str(ship.angular_dampen)
	if player != null:
		$Values/Toggles/mag_boots.text = str(player.mag_boots)
		$Values/Toggles/camera_rotate.text = str(camera.rotate)
		$Values/Toggles/jetpack.text = str(player.jetpack)
	
		$Values/State/sitting.text = str(player.sitting)
		$Values/State/grounded.text = str(player.grounded)
		$Values/State/fall.text = str(player.fall)
	
	var slots = $Hotbar.get_children()
	var pos = 0
	for i in slots:
		if pos != player.hotbar_pos:
			i.self_modulate = Color(1,1,1,1)
		else:
			i.self_modulate = Color(20,20,20,1)
		#i.get_node("TextureRect").texture = load("res://Assets/icons/"+player.hotbar[pos]+".png")
		pos += 1
