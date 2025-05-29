extends RigidBody2D

var speed = 500
var damp = 1
var Aspeed = 5
var Adamp = 1 # smaller stronger
var threashold = 0.05
#control vars
var angular_dampen = false
var linear_dampen = true
var angle = 0
var direction = Vector2(0,0)

@onready var player = %Player
@onready var tile_map = $TileMap

var controls = {
	"rcs_forward"	:[],
	"rcs_backward"	:[],
	"rcs_left"		:[],
	"rcs_right"		:[],
	"rcs_cw"		:[],
	"rcs_ccw"		:[]
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tile_map.update_tiles()
	angular_velocity = 0

	#position = Vector2(100,500)

func add_controls() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#control logic
	if angular_dampen:
		if -threashold <= angular_velocity and angular_velocity <= threashold: # if small
			angular_velocity = 0
		if angle == 0: # if not also holding key TODO add range for controller?
			angular_velocity -= angular_velocity/Adamp * delta
	if linear_dampen:
		if -threashold <= linear_velocity.x and linear_velocity.x <= threashold: # if small
			linear_velocity.x = 0
		if -threashold <= linear_velocity.y and linear_velocity.y <= threashold: # if small
			linear_velocity.y = 0
		if direction.x == 0:
			linear_velocity.x -= linear_velocity.x/damp * delta
		if direction.y == 0:
			linear_velocity.y -= linear_velocity.y/damp * delta
		
	#setting values
	direction = direction.rotated(rotation)
	linear_velocity += direction * speed * delta
	angular_velocity += angle * Aspeed * delta
	
	#update globals


func _on_player_ship_control(dir,ang) -> void:
	direction = dir
	angle = ang

	
