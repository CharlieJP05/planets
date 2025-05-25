extends Control
#@onready var player = get_node("../Player")
@onready var ship = %Ship
@onready var player = %Player
@onready var camera = %Camera2D

var offset = Vector2(0, 0)

func _process(delta):
	$Values/Velocity/linear.text = String("%.2f" % ship.linear_velocity.length())
	$Values/Velocity/angular.text = String("%.2f" % ship.angular_velocity)
	
	$Values/Position/linear.text = String("%.2f" % ship.position.length())
	$Values/Position/angular.text = String("%.2f" % ship.rotation)
	
	$Values/Dampeners/linear.text = str(player.linear_dampen)
	$Values/Dampeners/angular.text = str(player.angular_dampen)
	
	$Values/Toggles/mag_boots.text = str(player.mag_boots)
	$Values/Toggles/camera_rotate.text = str(camera.rotate)
	$Values/Toggles/jetpack.text = str(player.jetpack)
	
	$Values/State/sitting.text = str(player.sitting)
	$Values/State/grounded.text = str(player.grounded)
	$Values/State/fall.text = str(player.fall)
