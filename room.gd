extends Area2D

class_name Room

@export var cell_size = 24

var range_x
var range_y

var has_path_to = []

func initialize_variables(range_x: Vector2i, range_y: Vector2i) -> void:
	self.range_x = range_x
	self.range_y = range_y
	
	self.set_position(Vector2((range_x.y + range_x.x) * cell_size / 2, (range_y.y + range_y.x) * cell_size / 2))
