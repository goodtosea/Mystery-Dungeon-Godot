extends Area2D

class_name Floor;

var room_list := Array()
var room = preload("res://room.tscn")

@export var width := 56
@export var height := 32
@export var hard_border_width := 2

@export var M := 2
@export var N := 3


@export var seed := 1

# Called when the node enters the scene tree for the first time.
func _ready(seed: int = 1) -> void:
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
	for x in width:
		for y in height:
			$Layout.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 1), 0)
	


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
			room_list.append(current_room)
			add_child(current_room)
			
		
	# for each room, run place_room(x, y)
	for room in room_list:
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
	pass
	


# Debug for floor generation
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload debug"):
		get_tree().reload_current_scene()


static func own(node, new_owner):
	if not node == new_owner and (not node.owner or node.filename):
		node.owner = new_owner
	if node.get_child_count():
		for kid in node.get_children():
			own(kid, new_owner)
