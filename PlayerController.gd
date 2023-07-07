extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var currchar = []
var numchar = 0
@export var currnumchar = 0
var cam

# Called when the node enters the scene tree for the first time.

func _ready():
	for i in get_node("Players").get_children():
		currchar.append(i)
		i.selection = numchar
		print(i.selection)
		numchar += 1
	currchar[currnumchar].selected = true
	currchar[currnumchar].get_node("Camera2D").make_current()

# Called every frame. 'delta' is the elapsed time since the previous frame.	
func _input(ev):
	if ev.is_action_pressed("changechar"):
		currchar[currnumchar].selected = false
		var cam1 = currchar[currnumchar].get_node("Camera2D")
		print("Changed character")
		if currnumchar == numchar-1:
			currnumchar = 0
		else:
			currnumchar += 1
		
		currchar[currnumchar].selected = true
		var cam2 = currchar[currnumchar].get_node("Camera2D")
		TweenCam(cam1, cam2)
		currchar[currnumchar].get_node("Camera2D").make_current()
		
func TweenCam(cam1, cam2):
	pass
	#TWEEN FUNCTION HERE
