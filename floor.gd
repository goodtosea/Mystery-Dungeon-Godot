extends Area2D

# class_name floor;

@export var width := 56;
@export var height := 32;

@export var seed := 1;

# Called when the node enters the scene tree for the first time.
func _ready(seed: int = 1) -> void:
	setup_layout()



func setup_layout() -> void:
	fill_with_walls()
#	place_rooms()
#	place_corridors()
#	place_deadends()
#	draw_border()
#	place_exception_tiles()
#	place_terrain_features()
	
	
func fill_with_walls() -> void:
	for x in width:
		for y in height:
			$Layout.set_cell(0, Vector2i(x, y), 0, Vector2i(1, 1), 0)
			

# Debug for floor generation
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reload debug"):
		get_tree().reload_current_scene()

