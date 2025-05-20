extends Camera2D
@onready var player = get_node("../Player")


var shift = Vector2(0, 0)

func _ready():
	make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = player.position + shift
