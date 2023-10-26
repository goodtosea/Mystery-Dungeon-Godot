extends Node

@export var currentSeed : int = 1

func _ready() -> void:
	
	if currentSeed != 1:
		print("GIVEN SEED: ", currentSeed)
	else:
		currentSeed = randi()
		print("RANDOM SEED: ", currentSeed)
	
	seed(currentSeed)
