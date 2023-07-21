extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var currchar = []
var numchar = 0
var Moving

@onready var cam = $Camera
var lerpspeed = .1

var currnumchar = 0
@export var CurrentlySelected: CharacterBody2D

# Called when the node enters the scene tree for the first time.

func _ready():
	for i in get_node("Players").get_children():
		currchar.append(i)
		i.selection = numchar
		print(i.selection)
		numchar += 1
	cam.reparent(currchar[currnumchar])
	CurrentlySelected = currchar[currnumchar]
	cam.position = Vector2(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(ev):
	if ev.is_action_pressed("changechar"):
		print("Changed character")
		if currnumchar == numchar-1:
			currnumchar = 0
		else:
			currnumchar += 1
		CurrentlySelected.ChangeMotion(Vector2.ZERO)
		CurrentlySelected = currchar[currnumchar]
		cam.reparent(CurrentlySelected)
	if ev.is_action_pressed("click"):
		Moving = true
	if ev.is_action_released("click"):
		Moving = false
		
func _process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	CurrentlySelected.ChangeMotion(direction)
	if Moving:
		CurrentlySelected.MoveTo(get_global_mouse_position(), true)

# Called every physics frame. Used to handle camera follow and tweening.
func _physics_process(delta):
	cam.position = lerp(cam.position, Vector2(0, 0), lerpspeed)

