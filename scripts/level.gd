extends Node2D

var Ship = preload("res://scenes/secondary/ship.tscn")
var Player = preload("res://scenes/secondary/player.tscn")
var OtherPlayer = preload("res://scenes/secondary/OtherPlayer.tscn")
var Asteroid = preload("res://scenes/secondary/asteroid.tscn")

var player
var ships = {}
func _ready() -> void:
	
	ships = {
		"Ship1" : Ship.instantiate(),
		"Ship2" : Ship.instantiate()
	}
	add_child(ships["Ship1"])
	ships["Ship1"].position +=Vector2(500,0)
	add_child(ships["Ship2"])
	
	player = Player.instantiate()
	add_child(player)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func create_ship(floor: TileMapLayer,walls: TileMapLayer,build: TileMapLayer):
	var ship = Ship.instantiate()
	add_child(ship)
	ship.name = "Ship1"

	#ship.get_node("TileMap").get_node("Floor") = floor

func save_ship(ship):
	print("Saving....")
	var floor_map = ship.get_node("Floor")
	var size = floor_map.get_used_rect()
	for x in range(size.position.x, size.position.x + size.size.x):
		for y in range(size.position.y, size.position.y + size.size.y):
			var pos = Vector2(x,y)
			var data = floor_map.get_cell_tile_data(pos)
			if data == null:
				continue
			var floor_data = {}
			floor_data[str(pos)] = {
				"flip_h" : data.flip_h,
				"flip_v" : data.flip_v,
				"transpose" : data.transpose,
				"tile" : data.get_cell_atlas_coords(1,pos)
			}
			print(floor_data)
			print("2")
