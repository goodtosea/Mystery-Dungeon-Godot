extends Area2D

class_name Floor;

var room_list := []

var room = preload("res://room.tscn")

@export var width := 56
@export var height := 32
@export var hard_border_width := 2

@export var M := 2
@export var N := 3


@export var seed := 1

func initalize_room_list():
	for i in N:
		room_list.append([])
		for j in M:
			room_list[i].append(0)


# Called when the node enters the scene tree for the first time.
func _ready(seed: int = 1) -> void:
	initalize_room_list()
	setup_layout()



func setup_layout() -> void:
	fill_with_walls()

	create_rooms()

	place_corridors()
#	place_deadends()
#	draw_border()
#	place_exception_tiles()
#	place_terrain_features()


func fill_with_walls() -> void:
	draw_area(Vector2i(0, width), Vector2i(0, height), 0, 0, Vector2i(1, 1), 0)
	


func create_rooms() -> void:

#	place_room(Vector2i(hard_border_width, width - hard_border_width), 
#		Vector2i(hard_border_width, height - hard_border_width)) # generates one large room

	# get room bounds (goes 0 to N - 1 supposedly)
	for i in N:
		for j in M:
			# Sector logic
			var range_x := Vector2i(i * (width / N), (i + 1) * (width / N)) 
			var range_y := Vector2i(j * (height / M), (j + 1) * (height / M))
			
			var sector_size_x = range_x.y - range_x.x
			var sector_size_y = range_y.y - range_y.x
	
			var room_size_x := randi_range(5, sector_size_x)
			var room_size_y := randi_range(4, sector_size_y)

			var offset_x := randi_range(range_x.x, range_x.y - room_size_x)
			var offset_y := randi_range(range_y.x, range_y.y - room_size_y)
			
			# TODO: There's probably a better way to do this with signals
			
			var current_room = room.instantiate()
			current_room.initialize_variables(Vector2i(offset_x, offset_x + room_size_x), Vector2i(offset_y, offset_y + room_size_y))
			room_list[i][j] = current_room
			add_child(current_room)
			
		
	# for each room, run place_room(x, y)
	for column in room_list:
		for room in column:
			draw_room(room)
	


func draw_room(room: Room) -> void:
	for x in room.range_x:
		for y in room.range_y:
			$Layout.set_cell(0, Vector2i(x, y), 0, Vector2i(13, 1), 0)
		
#	var sector_size_x = range_x.y - range_x.x
#	var sector_size_y = range_y.y - range_y.x
#
#	var room_size_x := randi_range(5, sector_size_x) # replace 10 with size of sector later
#	var room_size_y := randi_range(4, sector_size_y)
#
#	# var offset_x := randi_range(hard_border_width, width - hard_border_width - room_size_x)
#	# var offset_y := randi_range(hard_border_width, height - hard_border_width - room_size_y)
#
#	var offset_x := randi_range(range_x.x, range_x.y - room_size_x)
#	var offset_y := randi_range(range_y.x, range_y.y - room_size_y)

	# offset picks a point within the playing space accounting for the border
	


func place_corridors() -> void:
	for i in N:
		for j in M:
			var current_room = room_list[i][j]
			var room_to_connect_to
			
			#above
			if (j - 1) > -1:
				room_to_connect_to = room_list[i][j - 1]
				
				var current_room_x = randi_range(current_room.range_x.x, current_room.range_x.y - 1) # -1 since width of the path will be 1
				var room_to_connect_to_x = randi_range(room_to_connect_to.range_x.x, room_to_connect_to.range_x.y - 1) # -1 since width of the path will be 1
				var corridor_connection_y = randi_range(min(current_room.range_y.x, room_to_connect_to.range_y.y) + 1, max(current_room.range_y.x, room_to_connect_to.range_y.y) - 1) # +1 and -1 so it doesn't include the walls

				draw_area(Vector2i(current_room_x, current_room_x + 1), Vector2i(min(corridor_connection_y, current_room.range_y.x), max(corridor_connection_y, current_room.range_y.x)), 0, 0, Vector2i(13, 1), 0) # current room to the midpoint
				draw_area(Vector2i(room_to_connect_to_x, room_to_connect_to_x + 1), Vector2i(min(room_to_connect_to.range_y.y, corridor_connection_y), max(room_to_connect_to.range_y.y, corridor_connection_y)), 0, 0, Vector2i(13, 1), 0) # room to connect to to the midpoint
				draw_area(Vector2i(min(current_room_x, room_to_connect_to_x), max(current_room_x, room_to_connect_to_x) + 1), Vector2i(corridor_connection_y, corridor_connection_y + 1), 0, 0, Vector2i(13, 1), 0) # connect the two
#
				
			#below
			if (j + 1) < M:
				room_to_connect_to = room_list[i][j + 1]
				
				var current_room_x = randi_range(current_room.range_x.x, current_room.range_x.y - 1)
				var room_to_connect_to_x = randi_range(room_to_connect_to.range_x.x, room_to_connect_to.range_x.y - 1)
				var corridor_connection_y = randi_range(min(current_room.range_y.y, room_to_connect_to.range_y.x) + 1, max(current_room.range_y.y, room_to_connect_to.range_y.x) - 1)

				draw_area(Vector2i(current_room_x, current_room_x + 1), Vector2i(min(corridor_connection_y, current_room.range_y.x), max(corridor_connection_y, current_room.range_y.x)), 0, 0, Vector2i(13, 1), 0) # current room to the midpoint
				draw_area(Vector2i(room_to_connect_to_x, room_to_connect_to_x + 1), Vector2i(min(room_to_connect_to.range_y.y, corridor_connection_y), max(room_to_connect_to.range_y.y, corridor_connection_y)), 0, 0, Vector2i(13, 1), 0) # room to connect to to the midpoint
				draw_area(Vector2i(min(current_room_x, room_to_connect_to_x), max(current_room_x, room_to_connect_to_x) + 1), Vector2i(corridor_connection_y, corridor_connection_y + 1), 0, 0, Vector2i(13, 1), 0) # connect the two
				
			#left
			if (i - 1) > -1:
				room_to_connect_to = room_list[i - 1][j]
				
				var current_room_y = randi_range(current_room.range_y.x, current_room.range_y.y - 1)
				var room_to_connect_to_y = randi_range(room_to_connect_to.range_y.x, room_to_connect_to.range_y.y - 1)
				var corridor_connection_x = randi_range(min(current_room.range_x.x, room_to_connect_to.range_x.y) + 1, max(current_room.range_x.x, room_to_connect_to.range_x.y) - 1)

				draw_area(Vector2i(min(corridor_connection_x, current_room.range_x.x), max(corridor_connection_x, current_room.range_x.x)), Vector2i(current_room_y, current_room_y + 1), 0, 0, Vector2i(13, 1), 0) # current room to the midpoint
				draw_area(Vector2i(min(room_to_connect_to.range_x.y, corridor_connection_x), max(room_to_connect_to.range_x.y, corridor_connection_x)), Vector2i(room_to_connect_to_y, room_to_connect_to_y + 1), 0, 0, Vector2i(13, 1), 0) # room to connect to to the midpoint
				draw_area(Vector2i(corridor_connection_x, corridor_connection_x + 1), Vector2i(min(current_room_y, room_to_connect_to_y), max(current_room_y, room_to_connect_to_y) + 1), 0, 0, Vector2i(13, 1), 0) # connect the two
				
			#right
			if (i + 1) < N:
				room_to_connect_to = room_list[i + 1][j]
				
				var current_room_y = randi_range(current_room.range_y.x, current_room.range_y.y - 1)
				var room_to_connect_to_y = randi_range(room_to_connect_to.range_y.x, room_to_connect_to.range_y.y - 1)
				var corridor_connection_x = randi_range(min(current_room.range_x.y, room_to_connect_to.range_x.x) + 1, max(current_room.range_x.y, room_to_connect_to.range_x.x) - 1)
				
				draw_area(Vector2i(min(corridor_connection_x, current_room.range_x.y), max(corridor_connection_x, current_room.range_x.y)), Vector2i(current_room_y, current_room_y + 1), 0, 0, Vector2i(13, 1), 0) # current room to the midpoint
				draw_area(Vector2i(min(room_to_connect_to.range_x.x, corridor_connection_x), max(room_to_connect_to.range_x.x, corridor_connection_x)), Vector2i(room_to_connect_to_y, room_to_connect_to_y + 1), 0, 0, Vector2i(13, 1), 0) # room to connect to to the midpoint
				draw_area(Vector2i(corridor_connection_x, corridor_connection_x + 1), Vector2i(min(current_room_y, room_to_connect_to_y), max(current_room_y, room_to_connect_to_y) + 1), 0, 0, Vector2i(13, 1), 0) # connect the two
	

func draw_area(range_x: Vector2i, range_y: Vector2i, layer: int, source_id: int = -1, atlas_coords: Vector2i = Vector2i(-1, -1), alternative_tile: int = 0):
	for x in range(range_x.x, range_x.y):
		for y in range(range_y.x, range_y.y):
			$Layout.set_cell(layer, Vector2i(x, y), source_id, atlas_coords, alternative_tile)

# Debug for floor generation
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload debug"):
		get_tree().reload_current_scene()
