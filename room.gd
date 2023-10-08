extends Area2D

class_name Room

var range_x
var range_y

func _init(range_x: Vector2i, range_y: Vector2i) -> void:
	self.range_x = range_x
	self.range_y = range_y
	
#	$CollisionShape2D.apply_scale(Vector2(range_x.y - range_x.x, range_y.y - range_y.x))

func draw_collider():
	
	$CollisionShape2D.apply_scale(Vector2(range_x.y - range_x.x, range_y.y - range_y.x))
