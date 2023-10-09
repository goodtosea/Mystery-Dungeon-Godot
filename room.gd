extends Area2D

class_name Room

var range_x
var range_y

var has_path_to = []

func initialize_variables(range_x: Vector2i, range_y: Vector2i) -> void:
	self.range_x = range_x
	self.range_y = range_y
	
	
	self.set_position(Vector2((range_x.y + range_x.x) * 24 / 2, (range_y.y + range_y.x) * 24 / 2))
	$CollisionShape2D.apply_scale(Vector2(range_x.y - range_x.x, range_y.y - range_y.x))
