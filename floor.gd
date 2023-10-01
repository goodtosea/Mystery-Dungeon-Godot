extends Area2D

# class_name floor;

@export var width := 56;
@export var height := 32;

@export var seed := 1;

# Called when the node enters the scene tree for the first time.
func _ready(seed: int = 1):
	setup_layout()



func setup_layout():
	fill_with_walls()
#	place_rooms()
#	place_corridors()
#	place_deadends()
#	draw_border()
#	place_exception_tiles()
#	place_terrain_features()
	
	
func fill_with_walls():
	for x in width:
		for y in height:
			$Layout.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 1), 0)

