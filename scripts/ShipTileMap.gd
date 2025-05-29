extends Node2D
@onready var hover = $Hover
@onready var build = $Build
@onready var floor = $Floor
@onready var walls = $Walls

@onready var ship = %Ship
var last_hover = Vector2(0,0)
var place_rot = 0
var place_flip = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func update_tiles() -> void:
	var size = walls.get_used_rect()
	for x in range(size.position.x, size.position.x + size.size.x):
			for y in range(size.position.y, size.position.y + size.size.y):
				var pos = Vector2(x,y)
				var data = walls.get_cell_tile_data(pos)
				# Deal with empty boxes
				if data == null:
					continue
				# Deal with thrust applyers
				var custom = data.get_custom_data("Thrust")
				if custom != []:
					pass
					# figure out rotation of thruster with flip_h and flip_v
					#if !data.flip_h and :
						#left
					#elif data.flip
					# for each thruster direction:
					# get its rotation and set that one dir to ship controls
					# looks like: "left": [[cell,thruster],[cell,thruster],[cell,thruster]]
					#if custom: #something someting
						#ship.controls[] walls.erase_cell(pos) TODO
				

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_key"):
		var size = build.get_used_rect()  # Get the rectangle of used cells
		for x in range(size.position.x, size.position.x + size.size.x):
			for y in range(size.position.y, size.position.y + size.size.y):
				if build.get_cell_source_id(Vector2(x,y)) != -1:
					floor.set_cell(Vector2(x,y),build.get_cell_source_id(Vector2(x,y)),build.get_cell_atlas_coords(Vector2(x,y)))
					build.erase_cell(Vector2(x,y))
	
func place(pos) -> void:
	var mouse_local_pos = build.get_local_mouse_position()
	var cell = build.local_to_map(mouse_local_pos)
	build.set_cell(cell,1,pos)
	#rotate_cell(build,cell,place_rot,place_flip)

func unplace() -> void:
	var mouse_local_pos = build.get_local_mouse_position()
	var cell = build.local_to_map(mouse_local_pos)
	build.erase_cell(cell)
	#rotate_cell(build,cell,place_rot,place_flip)
	
	
func destroy() -> void:
	var mouse_local_pos = floor.get_local_mouse_position()
	var cell = floor.local_to_map(mouse_local_pos)
	floor.erase_cell(cell)
	#rotate_cell(floor,cell,place_rot,place_flip)
	
func create(pos) -> void:
	var mouse_local_pos = floor.get_local_mouse_position()
	var cell = floor.local_to_map(mouse_local_pos)
	floor.set_cell(cell,1,pos)
	#rotate_cell(floor,cell,place_rot,place_flip)

func hover_cell(pos) -> void:
	hover.set_cell(last_hover,1)
	var mouse_local_pos = hover.get_local_mouse_position()
	var cell = hover.local_to_map(mouse_local_pos)
	last_hover = cell
	hover.set_cell(cell,1,pos)
	#rotate_cell(hover,cell,place_rot,place_flip)

#func rotate_cell(map, cell: Vector2i, rot: int, flip: bool) -> void:
	#var tile_data = map.get_cell_tile_data(cell)
	#if tile_data == null:
		#return
#
	#var new_tile = tile_data.duplicate()
	#
	## Get current transform
	#var current_rot = tile_data.get_rotation()
	#var current_flip = tile_data.is_flipped_horizontally()
	#
	## Rotate (wrap 0-3)
	#var new_rot = (current_rot + rot) % 4
	#var new_flip = current_flip != flip  # XOR to toggle flip
	#
	#new_tile.set_transform(new_rot, new_flip, tile_data.is_flipped_vertically())
#
	## Reapply cell with same tile info, and updated transform
	#map.set_cell(0, cell, tile_data.get_source_id(), tile_data.get_atlas_coords(), tile_data.get_alternative_tile())
	#map.set_cell_tile_data(0, cell, new_tile)



	
func get_clicked_tile_power():
	var clicked_cell = floor.local_to_map(floor.get_local_mouse_position())
	var data = floor.get_cell_tile_data(clicked_cell)
	if data:
		return data.get_custom_data("power")
	else:
		return 0
	
func get_tile_rotation_and_flip(tile_data: TileData) -> Dictionary:
	var flip_h = tile_data.flip_h
	var flip_v = tile_data.flip_v
	var transpose = tile_data.transpose

	var rotation = 0
	var flipped = false

	match [flip_h, flip_v, transpose]:
		[false, false, false]: rotation = 0;   flipped = false
		[true,  false, false]: rotation = 0;   flipped = true
		[false, true,  false]: rotation = 180; flipped = true
		[true,  true,  false]: rotation = 180; flipped = false
		[false, false, true]:  rotation = 90;  flipped = true
		[true,  false, true]:  rotation = 90;  flipped = false
		[false, true,  true]:  rotation = 270; flipped = false
		[true,  true,  true]:  rotation = 270; flipped = true

	return {
		"rotation_degrees": rotation,
		"is_flipped": flipped
	}
	
func get_flip_transpose_from_rotation_and_flip(rotation_degrees: int, is_flipped: bool) -> Dictionary:
	var flip_h = false
	var flip_v = false
	var transpose = false

	match [rotation_degrees % 360, is_flipped]:
		[0, false]:
			flip_h = false
			flip_v = false
			transpose = false
		[0, true]:
			flip_h = true
			flip_v = false
			transpose = false
		[180, true]:
			flip_h = false
			flip_v = true
			transpose = false
		[180, false]:
			flip_h = true
			flip_v = true
			transpose = false
		[90, true]:
			flip_h = false
			flip_v = false
			transpose = true
		[90, false]:
			flip_h = true
			flip_v = false
			transpose = true
		[270, false]:
			flip_h = false
			flip_v = true
			transpose = true
		[270, true]:
			flip_h = true
			flip_v = true
			transpose = true

	return {
		"flip_h": flip_h,
		"flip_v": flip_v,
		"transpose": transpose
	}
