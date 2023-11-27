extends State
class_name OutOfGame

@export var character : CharacterBody2D
@onready var AreaHandler = get_node("/root/World/PlayingAreas")
@onready var restArea = get_node("/root/World/SideBorder/RestArea")

var dir : Vector2
var pos : Vector2
var wander_time : float

var spd = 24

var players: Array

func random_pos_area():
	print(character.name + " (" + character.currentTeam + ") is out, so retreating to RestArea")
	character.targetArea = restArea
	pos = AreaHandler.random_pos(restArea)
	wander_time = randf_range(6,10)
	
func disableSelf():
	if AreaHandler.checkIfInArea(character):
		Transitioned.emit(self, "Disable")
	else:
		random_pos_area()

var doubleCheckActive = false
func Enter():
	doubleCheckActive = true
	if not character:
		character = get_parent().get_parent()
	character.running = false
	character.DisableAreaRays.emit(true)
	character.DisablePlayerRays.emit(true)
	character.DisableBorderRays.emit(true)
	character.set_collision_mask(0)
	character.set_collision_layer(2)
	print("Moving out of game..")
	character.currentTeam = "Out"
	character.ReachedTarget.connect(disableSelf)
	random_pos_area()

func Exit():
	print("Exiting out of OutOfGame state for " + character.name)
	doubleCheckActive = false
	character.ReachedTarget.disconnect(disableSelf)
	
var wait = 1.245
func Update(delta):
	wait -= delta
	if wait <= 0 and doubleCheckActive:
		character.MoveTo(pos, spd)
		
func Physics_Update(_delta):
	pass
