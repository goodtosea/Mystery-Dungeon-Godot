extends Area2D

# class_name floor;

@export var width := 56
@export var height := 32
@export var hard_border_width := 2

@export var seed := 1

# Called when the node enters the scene tree for the first time.
func _ready(seed: int = 1) -> void:
	setup_layout()



func setup_layout() -> void:
	fill_with_walls()
	place_rooms()
#	place_corridors()
#	place_deadends()
#	draw_border()
#	place_exception_tiles()
#	place_terrain_features()
	
	
func fill_with_walls() -> void:
	for x in width:
		for y in height:
			$Layout.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 1), 0)
			


func place_rooms() -> void:
	
	var offset_x := randi_range(hard_border_width, width - hard_border_width)
	var offset_y := randi_range(hard_border_width, height - hard_border_width)
	
	var room_size_x := randi_range(5, 10) # replace 10 with size of sector later
	var room_size_y := randi_range(4, 10)
	for x in room_size_x:
		for y in room_size_y:
			$Layout.set_cell(0, Vector2i(x + offset_x, y + offset_y), 0, Vector2i(13, 1), 0)


# Debug for floor generation
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload debug"):
		get_tree().reload_current_scene()

