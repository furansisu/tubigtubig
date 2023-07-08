extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var currchar = []
var numchar = 0

@onready var cam = $Camera
var lerpspeed = .1

@export var currnumchar = 0

# Called when the node enters the scene tree for the first time.

func _ready():
	for i in get_node("Players").get_children():
		currchar.append(i)
		i.selection = numchar
		print(i.selection)
		numchar += 1
	currchar[currnumchar].selected = true
	cam.reparent(currchar[currnumchar])
	cam.position = Vector2(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(ev):
	if ev.is_action_pressed("changechar"):
		currchar[currnumchar].selected = false
		print("Changed character")
		if currnumchar == numchar-1:
			currnumchar = 0
		else:
			currnumchar += 1
		currchar[currnumchar].selected = true
		cam.reparent(currchar[currnumchar])

# Called every physics frame. Used to handle camera follow and tweening.
func _physics_process(delta):
	cam.position = lerp(cam.position, Vector2(0, 0), lerpspeed)

