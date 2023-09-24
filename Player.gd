extends Area2D

@export var tile_size = 24
var inputs = {
	"up": 			Vector2.UP,
	"up-right": 	Vector2.UP + Vector2.RIGHT,
	"right": 		Vector2.RIGHT,
	"down-right": 	Vector2.DOWN + Vector2.RIGHT,
	"down": 		Vector2.DOWN,
	"down-left": 	Vector2.DOWN + Vector2.LEFT,
	"left": 		Vector2.LEFT,
	"up-left": 		Vector2.UP + Vector2.LEFT
	}

@onready var ray = $RayCast2D

var animation_speed = 3
var moving = false


func _ready():
	position = position.snapped(Vector2.ONE * tile_size)
	position += Vector2.ONE * (tile_size/2)


func _physics_process(delta):
	movement_handling()
	


func movement_handling():
	if moving:
		return
	
	# TODO: make movement prioritize what was most recently pressed instead of rigidly like this
	if Input.is_action_pressed("up"):
		if Input.is_action_pressed("right"):
			move("up-right")
		elif Input.is_action_pressed("left"):
			move("up-left")
		else:
			move("up")
	elif Input.is_action_pressed("down"):
		if Input.is_action_pressed("right"):
			move("down-right")
		elif Input.is_action_pressed("left"):
			move("down-left")
			
			
			
		else:
			move("down")
	elif Input.is_action_pressed("left"):
		move("left")
	elif Input.is_action_pressed("right"):
		move("right")


func move(direction):
	ray.target_position = inputs[direction] * tile_size
	ray.force_raycast_update()
	if !ray.is_colliding():
		#position += inputs[dir] * tile_size
		var tween = create_tween()
		tween.tween_property(self, "position",
			position + inputs[direction] * tile_size, 1.0/animation_speed).set_trans(Tween.TRANS_SINE)
		moving = true
		await tween.finished
		moving = false
