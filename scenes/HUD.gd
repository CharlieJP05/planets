extends Control
#@onready var player = get_node("../Player")
@onready var player = %Player
@onready var camera = $Camera2D

var offset = Vector2(0, 0)

func _process(delta):
	$Panel/Velocity/linear.text = String("%.2f" % player.linear_velocity.length())
	$Panel/Velocity/angular.text = String("%.2f" % player.angular_velocity)
