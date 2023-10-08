extends Area2D

class_name Room

var range_x
var range_y

func _init(range_x: Vector2i, range_y: Vector2i) -> void:
	self.range_x = range_x
	self.range_y = range_y

