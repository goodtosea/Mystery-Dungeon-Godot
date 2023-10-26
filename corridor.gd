extends Node2D

class_name Corridor

var end_point_1
var end_point_2

var mid_point
var direction 

func initialize_variables(end_point_1: Vector2i, end_point_2: Vector2i, mid_point: int, direction: int) -> void:
	self.end_point_1 = end_point_1
	self.end_point_2 = end_point_2
	
	self.mid_point = mid_point
	self.direction = direction
