extends Area2D

# class_name floor;

@export var width := 56
@export var height := 32
@export var hard_border_width := 2

@export var M := 2
@export var N := 2


@export var seed := 1

# Called when the node enters the scene tree for the first time.
func _ready(seed: int = 1) -> void:
	setup_layout()



func setup_layout() -> void:
	fill_with_walls()

	create_sectors_and_rooms()

#	place_corridors()
#	place_deadends()
#	draw_border()
#	place_exception_tiles()
#	place_terrain_features()
	
	
func fill_with_walls() -> void:
	for x in width:
		for y in height:
			$Layout.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 1), 0)
			


func place_room(range_x: Vector2i, range_y: Vector2i) -> void:

	var room_size_x := randi_range(5, range_x.y) # replace 10 with size of sector later
	var room_size_y := randi_range(4, range_y.y)

	# var offset_x := randi_range(hard_border_width, width - hard_border_width - room_size_x)
	# var offset_y := randi_range(hard_border_width, height - hard_border_width - room_size_y)

	var offset_x := randi_range(range_x.x, range_x.y - room_size_x)
	var offset_y := randi_range(range_y.x, range_y.y - room_size_y)

	# offset picks a point within the playing space accounting for the border
	
	for x in room_size_x:
		for y in room_size_y:
			$Layout.set_cell(0, Vector2i(x + offset_x, y + offset_y), 0, Vector2i(13, 1), 0)


func create_sectors_and_rooms():

	place_room(Vector2i(hard_border_width, width - hard_border_width), 
		Vector2i(hard_border_width, height - hard_border_width)) # generates one large room

	# get sector bounds

	# for each sector, run place_room(x, y)


# Debug for floor generation
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload debug"):
		get_tree().reload_current_scene()

