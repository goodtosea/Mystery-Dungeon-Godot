extends Area2D

class_name Floor

var room_list_2D := []

var room = preload("res://room.tscn")

# TODO: figure out how to keep rooms from generating in the border (smaller size and draw walls on the outside?)
@export var border_width := 2
@export var width := 56 - border_width
@export var height := 32 - border_width
@export var dead_ends := 1

@export var room_density := 2

@export var floor_use_percent := 100
@export var room_merge_percent := 5

@export var M := 2
@export var N := 3

# === Common Functions

func initalize_room_list_2D() -> void:
	for i in N:
		room_list_2D.append([])
		for j in M:
			room_list_2D[i].append(0)


func flattened_room_list_2D() -> Array:
	var flattened_list = Array()
	
	for col in room_list_2D:
		for room in col:
			flattened_list.append(room)
			
	return flattened_list


func get_neighbors(room: Room) -> Array:
	
	var i = -1
	var j = -1
	
	# get rooms coordinates in room_list_2D
	for col in room_list_2D:
		if col.find(room) > -1:
			j = col.find(room)
			i = room_list_2D.find(col)
	
	assert(i != -1 and j != -1) # TODO: Better permanent solution
	
	var neighbors = Array() # top: 0, bottom: 1, left: 2, right: 3
	for k in range(4):
		neighbors.append(null)
	
	if (j - 1) > -1: # top
		neighbors[0] = room_list_2D[i][j - 1]
	if (j + 1) < M: # bottom
		neighbors[1] = room_list_2D[i][j + 1]
	if (i - 1) > -1: # left
		neighbors[2] = room_list_2D[i - 1][j]
	if (i + 1) < N: # right
		neighbors[3] = room_list_2D[i + 1][j]
	
	return neighbors


func draw_area(range_x: Vector2i, range_y: Vector2i, layer: int, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0):
	# Guard to make sure the range values are increasing order
	if range_x.y < range_x.x:
		var temp = range_x.y
		range_x.y = range_x.x
		range_x.x = temp
	if range_y.y < range_y.x:
		var temp = range_y.y
		range_y.y = range_y.x
		range_y.x = temp
	
	for x in range(range_x.x, range_x.y):
		for y in range(range_y.x, range_y.y):
			$Layout.set_cell(layer, Vector2i(x, y), source_id, atlas_coords, alternative_tile)


func draw_area_floor(range_x: Vector2i, range_y: Vector2i):
	draw_area(range_x, range_y, 0, 0, Vector2i(13, 1), 0)


func draw_area_wall(range_x: Vector2i, range_y: Vector2i):
	draw_area(range_x, range_y, 0, 0, Vector2i(1, 1), 0)


# === Initialization

func _ready() -> void:
	initalize_room_list_2D()
	setup_layout()


func setup_layout() -> void:
	fill_area_with_wall_tiles()

	create_rooms()

	place_corridors()
	place_deadends(dead_ends)
	draw_border()
	# place_exception_tiles()
	# place_terrain_features()

# === Fill With Wall Tiles Functions

func fill_area_with_wall_tiles() -> void:
	draw_area(Vector2i(0, width), Vector2i(0, height), 0, 0, Vector2i(1, 1), 0)

# === Create Rooms Functions

func create_rooms() -> void: 
	# get room bounds
	for i in N:
		for j in M:
			# Sector logic
			var range_x := Vector2i(i * (width / N) + 1, (i + 1) * (width / N) - 1) 
			var range_y := Vector2i(j * (height / M) + 1, (j + 1) * (height / M) - 1)
			
			var sector_size_x = range_x.y - range_x.x
			var sector_size_y = range_y.y - range_y.x
	
			var room_size_x := randi_range(5, sector_size_x)
			var room_size_y := randi_range(4, sector_size_y)

			var offset_x := randi_range(range_x.x, range_x.y - room_size_x)
			var offset_y := randi_range(range_y.x, range_y.y - room_size_y)
			
			# TODO: There's probably a better way to do this with signals
			
			var current_room = room.instantiate()
			current_room.initialize_variables(Vector2i(offset_x, offset_x + room_size_x), Vector2i(offset_y, offset_y + room_size_y))
			room_list_2D[i][j] = current_room
			add_child(current_room)
	
	# before drawing, make the dummy 1x1 rooms randomly selecting from room_list
	var rooms_to_make_1x1 := M * N - room_density_handling()
	var flattened_room_list = flattened_room_list_2D()
	var current_room
	flattened_room_list.shuffle() # randomize rooms so we can pop
	
	while rooms_to_make_1x1 > 0:
		current_room = flattened_room_list.pop_front()
		current_room.range_x.y = current_room.range_x.x + 1
		current_room.range_y.y = current_room.range_y.x + 1
		current_room.reset_position()
		rooms_to_make_1x1 -= 1
	
	for column in room_list_2D:
		for room in column:
			draw_room(room)


func room_density_handling() -> int:
	# Can't have a map with less than 2 rooms
	var temp := room_density
	var non_dummy_rooms := 0
	if -2 < room_density and room_density < 0:
		temp = -2
	if 0 <= room_density and room_density < 2:
		temp = 2
	
	
	# negative number is exact, positive is between room_density and the max number of rooms
	if temp < 0:
		non_dummy_rooms = abs(temp)
	else:
		non_dummy_rooms = randi_range(temp, M * N)
	
	return non_dummy_rooms


func draw_room(room: Room) -> void:
	for x in room.range_x:
		for y in room.range_y:
			$Layout.set_cell(0, Vector2i(x, y), 0, Vector2i(13, 1), 0)

# === Place Corridor Functions

func place_corridors() -> void:
	var unvisited = flattened_room_list_2D()
	var visited = Array()
	
	var current = unvisited.pick_random()
	unvisited.erase(current)
	visited.append(current)
	
	# === Creates what is basically a connected undirected map from the rooms
	
	while not unvisited.is_empty():
		var neighbors = get_neighbors(current)
		var neighbor
		while neighbor == null:
			neighbor = neighbors.pick_random() # TODO: Minor code optimization possible since this has theoretical T(n) = infinity
		var side_to_draw_corridor = neighbors.find(neighbor)
		if not visited.has(neighbor):
			draw_corridor(current, neighbor, side_to_draw_corridor)
			unvisited.erase(neighbor)
			visited.append(neighbor)
		current = neighbor
	
	# === Calculate the number of extra corridors to spawn
	
	if N < 2 or M < 2: # Guard clause for when the minimum corridors is the maximum
		return
	
	var corner_rooms = 4 							# can have up to 2 corridors
	var edge_rooms = 2 * (N - 2) + 2 * (M - 2) 		# can have up to 3 corridors
	var inside_rooms = M * N - 2 * (N - M + 2) 		# can have up to 4 corridors
	
	var max_corridors = corner_rooms * 2 + edge_rooms * 3 + inside_rooms * 4
	var corridors_left = randi_range(0, max_corridors - (M * N - 1))
	
	# === Draws extra corridors
	
	var flat_room_list = flattened_room_list_2D()
	
	while corridors_left > 0:
		current = flat_room_list.pick_random()
		var neighbors = get_neighbors(current)
		
		# culls neighbors we already have a path to
		for neighbor in neighbors:
			if current.connected_rooms.has(neighbor):
				neighbor = null
		
		# continue if all the adjacent rooms are already connected to
		if neighbors.count(null) == neighbors.size(): 
			continue
		
		var neighbor
		while neighbor == null:
			neighbor = neighbors.pick_random() # TODO: Minor code optimization possible since this has theoretical T(n) = infinity
		
		var side_to_draw_corridor = neighbors.find(neighbor) # TODO: get_neighbors saves them in a not obvious specific order of (0: top, 1: bottom, 2: left, 3: right)
		draw_corridor(current, neighbor, side_to_draw_corridor)
		corridors_left -= 1


func draw_corridor(room: Room, neighbor: Room, side_to_draw_corridor: int):
	var current_room = room
	var room_to_connect_to = neighbor
	
	if current_room.connected_rooms.has(room_to_connect_to) or current_room == null or neighbor == null:
		return
	
	match side_to_draw_corridor:
		0:
			var current_room_x = randi_range(current_room.range_x.x, current_room.range_x.y - 1) 						# -1 since width of the path will be 1
			var room_to_connect_to_x = randi_range(room_to_connect_to.range_x.x, room_to_connect_to.range_x.y - 1) 		# -1 since width of the path will be 1
			var corridor_connection_y = randi_range(room_to_connect_to.range_y.y + 1, current_room.range_y.x - 2) 		# +1 and -1 so it doesn't include the walls

			draw_area_floor(Vector2i(current_room_x, current_room_x + 1), Vector2i(corridor_connection_y, current_room.range_y.x)) 																# current_room to the midpoint
			draw_area_floor(Vector2i(room_to_connect_to_x, room_to_connect_to_x + 1), Vector2i(room_to_connect_to.range_y.y, corridor_connection_y)) 											# room_to_connect to to the midpoint
			draw_area_floor(Vector2i(min(current_room_x, room_to_connect_to_x), max(current_room_x, room_to_connect_to_x) + 1), Vector2i(corridor_connection_y, corridor_connection_y + 1)) 	# straight line between the two ends
			
		1:
			var current_room_x = randi_range(current_room.range_x.x, current_room.range_x.y - 1)
			var room_to_connect_to_x = randi_range(room_to_connect_to.range_x.x, room_to_connect_to.range_x.y - 1)
			var corridor_connection_y = randi_range(current_room.range_y.y + 1, room_to_connect_to.range_y.x - 2)

			draw_area_floor(Vector2i(current_room_x, current_room_x + 1), Vector2i(current_room.range_y.y, corridor_connection_y))
			draw_area_floor(Vector2i(room_to_connect_to_x, room_to_connect_to_x + 1), Vector2i(corridor_connection_y, room_to_connect_to.range_y.x))
			draw_area_floor(Vector2i(min(current_room_x, room_to_connect_to_x), max(current_room_x, room_to_connect_to_x) + 1), Vector2i(corridor_connection_y, corridor_connection_y + 1)) 
			
		2:
			var current_room_y = randi_range(current_room.range_y.x, current_room.range_y.y - 1)
			var room_to_connect_to_y = randi_range(room_to_connect_to.range_y.x, room_to_connect_to.range_y.y - 1)
			var corridor_connection_x = randi_range(room_to_connect_to.range_x.y + 1, current_room.range_x.x - 2)

			draw_area_floor(Vector2i(corridor_connection_x, current_room.range_x.x), Vector2i(current_room_y, current_room_y + 1))
			draw_area_floor(Vector2i(room_to_connect_to.range_x.y, corridor_connection_x), Vector2i(room_to_connect_to_y, room_to_connect_to_y + 1))
			draw_area_floor(Vector2i(corridor_connection_x, corridor_connection_x + 1), Vector2i(min(current_room_y, room_to_connect_to_y), max(current_room_y, room_to_connect_to_y) + 1))
		3:
			var current_room_y = randi_range(current_room.range_y.x, current_room.range_y.y - 1)
			var room_to_connect_to_y = randi_range(room_to_connect_to.range_y.x, room_to_connect_to.range_y.y - 1)
			var corridor_connection_x = randi_range(current_room.range_x.y + 1, room_to_connect_to.range_x.x - 2)

			draw_area_floor(Vector2i(current_room.range_x.y, corridor_connection_x), Vector2i(current_room_y, current_room_y + 1))
			draw_area_floor(Vector2i(corridor_connection_x, room_to_connect_to.range_x.x), Vector2i(room_to_connect_to_y, room_to_connect_to_y + 1))
			draw_area_floor(Vector2i(corridor_connection_x, corridor_connection_x + 1), Vector2i(min(current_room_y, room_to_connect_to_y), max(current_room_y, room_to_connect_to_y) + 1))
	
	current_room.connected_rooms.append(room_to_connect_to)
	room_to_connect_to.connected_rooms.append(current_room)
	
	if randi_range(0, 100) < room_merge_percent:
		merge_rooms(current_room, room_to_connect_to)
		draw_room(current_room) # TODO: if merge_rooms returns early this is a waste


func merge_rooms(room_1: Room, room_2: Room):
	if room_1.get_area() == 1 or room_2.get_area() == 1:
		return
	
	var new_room_range_x := Vector2i(min(room_1.range_x.x, room_2.range_x.x), max(room_1.range_x.y, room_2.range_x.y))
	var new_room_range_y := Vector2i(min(room_1.range_y.x, room_2.range_y.x), max(room_1.range_y.y, room_2.range_y.y))
	
	# TODO: make this less jank
	room_1.range_x = new_room_range_x
	room_1.range_y = new_room_range_y
	room_2.range_x = new_room_range_x
	room_2.range_y = new_room_range_y

# === Place Deadend Functions

func place_deadends(deadends_left: int = 1 ):
	# iteratively generate/draw path (needs to take 2 steps in each direction at least)
	# until it has a floor or the border in one of the 8 spots around it
	var flat_room_list = flattened_room_list_2D()
	var current_room
	
	var direction # 0 - top, 1 - bottom, 2 - left, 3 - right
	var new_direction
	
	var current_tile
	var last_tile # tracks the last tile so we don't check if it's a floor
	var surrounding_tiles
	
	while deadends_left:
		current_room = flat_room_list.pick_random() # pick room randomly
		direction = randi_range(0, 3) # pick one of its walls // 0 - top, 1 - bottom, 2 - left, 3 - right
		
		# initial movement from the wall
		match direction:
			0:
				# pick random point in the wall
				var current_room_x = randi_range(current_room.range_x.x, current_room.range_x.y - 1)
				current_tile = Vector2i(current_room_x, current_room.range_y.x)
				
				# initial two steps to get away from the room
				current_tile.y -= 1
				draw_cell_floor(current_tile)
				last_tile = current_tile
				current_tile.y -= 1
				draw_cell_floor(current_tile)
			1:
				var current_room_x = randi_range(current_room.range_x.x, current_room.range_x.y - 1)
				current_tile = Vector2i(current_room_x, current_room.range_y.x)
				
				current_tile.y += 1
				draw_cell_floor(current_tile)
				last_tile = current_tile
				current_tile.y += 1
				draw_cell_floor(current_tile)
			2:
				var current_room_y = randi_range(current_room.range_y.x, current_room.range_y.y - 1)
				current_tile = Vector2i(current_room.range_x.x, current_room_y)
				
				current_tile.x -= 1
				draw_cell_floor(current_tile)
				last_tile = current_tile
				current_tile.x -= 1
				draw_cell_floor(current_tile)
			3:
				var current_room_y = randi_range(current_room.range_y.x, current_room.range_y.y - 1)
				current_tile = Vector2i(current_room.range_x.y - 1, current_room_y)
				
				current_tile.x += 1
				draw_cell_floor(current_tile)
				last_tile = current_tile
				current_tile.x += 1
				draw_cell_floor(current_tile)
		
		# gets surrounding and removes last move
		surrounding_tiles = $Layout.get_surrounding_cells(current_tile)
		surrounding_tiles.erase(last_tile)
		
		# continuous movement until it hits an empty tile or a floor
		while deadend_tile_check(surrounding_tiles):
			match direction:
				0:
					new_direction = [0, 2, 3]
					new_direction = new_direction.pick_random()
					
					if new_direction == direction:
						last_tile = current_tile
						current_tile.y -= 1
					
					elif new_direction == 2:
						current_tile.x -= 1
						draw_cell_floor(current_tile)
						last_tile = current_tile
						current_tile.x -= 1
					
					else: # new_direction == 3
						current_tile.x += 1
						draw_cell_floor(current_tile)
						last_tile = current_tile
						current_tile.x += 1
				1:
					new_direction = [1, 2, 3]
					new_direction = new_direction.pick_random()
					
					if new_direction == direction:
						last_tile = current_tile
						current_tile.y += 1
					
					elif new_direction == 2:
						current_tile.x -= 1
						draw_cell_floor(current_tile)
						last_tile = current_tile
						current_tile.x -= 1
					
					else: # new_direction == 3
						current_tile.x += 1
						draw_cell_floor(current_tile)
						last_tile = current_tile
						current_tile.x += 1
				2:
					new_direction = [0, 1, 2]
					new_direction = new_direction.pick_random()
					
					if new_direction == direction:
						last_tile = current_tile
						current_tile.x -= 1
					
					elif new_direction == 0:
						current_tile.y += 1
						draw_cell_floor(current_tile)
						last_tile = current_tile
						current_tile.y += 1
					
					else: # new_direction == 1
						current_tile.y -= 1
						draw_cell_floor(current_tile)
						last_tile = current_tile
						current_tile.y -= 1
				3:
					new_direction = [0, 1, 3]
					new_direction = new_direction.pick_random()
					
					if new_direction == direction:
						last_tile = current_tile
						current_tile.x += 1
					
					elif new_direction == 0:
						current_tile.y += 1
						draw_cell_floor(current_tile)
						last_tile = current_tile
						current_tile.y += 1
					
					else: # new_direction == 1
						current_tile.y -= 1
						draw_cell_floor(current_tile)
						last_tile = current_tile
						current_tile.y -= 1
			direction = new_direction
			
			draw_cell_floor(current_tile)
			surrounding_tiles = $Layout.get_surrounding_cells(current_tile)
			surrounding_tiles.erase(last_tile)
		
		deadends_left -= 1


func draw_cell(coords: Vector2i, layer: int, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0):
	$Layout.set_cell(layer, Vector2i(coords.x, coords.y), source_id, atlas_coords, alternative_tile)


func draw_cell_floor(coords: Vector2i):
	draw_cell(coords, 0, 0, Vector2i(13, 1), 0)


func deadend_tile_check(surrounding_tiles: Array[Vector2i]) -> bool:
	var current_tile_source_id
	var current_tile_atlas_coords
	var current_tile_alternative_tile
	
	for tile in surrounding_tiles:
		current_tile_source_id 			= $Layout.get_cell_source_id(0, tile)
		current_tile_atlas_coords 		= $Layout.get_cell_atlas_coords(0, tile)
		current_tile_alternative_tile 	= $Layout.get_cell_alternative_tile(0, tile)
		
		# Floor tile check
		if current_tile_source_id == 0 and current_tile_atlas_coords == Vector2i(13, 1) and current_tile_alternative_tile == 0:
			return false
		# Empty tile check
		elif current_tile_source_id == 0 and current_tile_atlas_coords == Vector2i(5, 2) and current_tile_alternative_tile == 0:
			return false
		# Invalid(?) tile check
		elif current_tile_source_id == -1 and current_tile_atlas_coords == Vector2i(-1, -1) and current_tile_alternative_tile == -1:
			return false
	return true

# === Draw Border Functions

func draw_border():
	# top border
	draw_area_wall(Vector2i(-border_width, width + border_width), Vector2i(-border_width, 0))
	# bottom border
	draw_area_wall(Vector2i(-border_width, width + border_width), Vector2i(height, height + border_width))
	# left border
	draw_area_wall(Vector2i(-border_width, 0), Vector2i(0, height))
	# right border
	draw_area_wall(Vector2i(width, width + border_width), Vector2i(0, height))

# === Debug Functions

# default: r to reload scene
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload debug"):
		get_tree().reload_current_scene()
