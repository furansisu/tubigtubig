extends Node2D

var posVector: Vector2
@export var deadzone = 0

func _process(delta):
    if posVector:
        print(posVector)
