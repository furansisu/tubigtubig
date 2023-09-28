extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var currchar = []
var numchar = 0
var Moving
var ManualMove = false

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
		CurrentlySelected = currchar[currnumchar]
		cam.reparent(CurrentlySelected)
	if ev.is_action_pressed("click"):
		Moving = true
	if ev.is_action_released("click"):
		Moving = false
		
func _process(_delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	if ManualMove:
		CurrentlySelected.Move(direction, CurrentlySelected.maxspd)
	if direction == Vector2.ZERO and ManualMove:
		ManualMove = false
	if direction != Vector2.ZERO and not ManualMove:
		ManualMove = true
	if Moving:
		CurrentlySelected.MoveTo(get_global_mouse_position(), true, null)

# Called every physics frame. Used to handle camera follow and tweening.
func _physics_process(_delta):
	cam.position = lerp(cam.position, Vector2(0, 0), lerpspeed)

