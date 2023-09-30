extends Node2D

var currchar = []
var numchar = 0
var Moving
var ManualMove = false

@onready var cam = $Camera
var lerpspeed = .1

var currnumchar = 0
@export var CurrentlySelected: CharacterBody2D

func _ready():
	for i in get_node("Players").get_children():
		currchar.append(i)
		i.selection = numchar
		print(i.selection)
		numchar += 1
	cam.reparent(currchar[currnumchar])
	CurrentlySelected = currchar[currnumchar]
	CurrentlySelected.Selected.emit(true)
	cam.position = Vector2(0, 0)

func _input(ev : InputEvent):
	if ev.is_action_pressed("changechar"):
		print("Changed character")
		CurrentlySelected.Selected.emit(false)
		if currnumchar == numchar-1:
			currnumchar = 0
		else:
			currnumchar += 1
		CurrentlySelected = currchar[currnumchar]
		CurrentlySelected.Selected.emit(true)
		cam.reparent(CurrentlySelected)
	if ev.is_action_pressed("click"):
		CurrentlySelected.MoveTo(get_global_mouse_position(), null)
	if ev.is_action_pressed("run"):
		CurrentlySelected.RunBool(true)
	if ev.is_action_released("run"):
		CurrentlySelected.RunBool(false)
		
func _process(_delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	if ManualMove:
		CurrentlySelected.Move(direction, CurrentlySelected.defaultspd)
	if direction == Vector2.ZERO and ManualMove:
		ManualMove = false
	if direction != Vector2.ZERO and not ManualMove:
		ManualMove = true

func _physics_process(_delta):
	cam.position = lerp(cam.position, Vector2(0, 0), lerpspeed)

