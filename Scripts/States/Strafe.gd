extends State
class_name Strafe

@export var character : CharacterBody2D
@onready var AreaHandler = get_node("/root/World/PlayingAreas")

var dir : Vector2
var pos : Vector2
var wander_time : float

var sideLook = false

var players : Array

func randomize_wander():
	dir = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1,2)
	
func random_newpos():
	pos = Vector2(randi_range(-100,100), randi_range(-100,100)) + character.global_position
	wander_time = randf_range(6,10)

var prevPos = Vector2(0,0)
func random_pos_area():
#	print(character.name + ": GETTING RANDOM POS IN " + character.targetArea.name)
	if not character.targetArea:
		changeToNextArea()
	pos = AreaHandler.random_pos(character.targetArea)
#	print(character.name + ": NEW POSITION: " + str(pos) + " FROM " + str(prevPos))
	prevPos = pos
	wander_time = randf_range(1,2)
	
func changeToNextArea():
	character.targetArea = AreaHandler.getNextAreaOfCharacter(character)
	sideLook = false

func changeToSideArea():
	var sideArea = AreaHandler.getSideAreaOfCharacter(character)
#	print("CHANGING AREA FOR " + character.name + " FROM " + character.targetArea.name + " TO " + sideArea.name)
	character.targetArea = sideArea
	sideLook = true
	character.movingToSide = true
	random_pos_area()
	
func checkLowestDistanceToTagger():
	var distances : Dictionary = {}
	var lowestDist = 9999
	
	if sideLook == true:
		for i in players:
			if i.middleLine == true:
				return i.global_position.distance_to(character.global_position)
		wander_time = 0
		return 9999
	
	for i in players:
		distances[i.name] = i.global_position.distance_to(character.global_position)
	
	for target in distances:
		if distances[target] <= lowestDist:
			lowestDist = distances[target]
	
	character.distanceToClosestTagger = lowestDist
	return lowestDist

func Enter():
	if not character:
		character = get_parent().get_parent()
	if not AreaHandler.checkIfInArea(character):
			Transitioned.emit(self, "Forward")
	character.movingToSide = false
	random_pos_area()
	changeToNextArea()
	character.DisableAreaRays.emit(false)
	character.DisablePlayerRays.emit(false)
	character.DisableBorderRays.emit(false)
	character.ReachedTarget.connect(random_pos_area)
	players = get_node("/root/World").Taggers

func Exit():
	if character.ReachedTarget.is_connected(random_pos_area):
		character.ReachedTarget.disconnect(random_pos_area)
	
func Update(delta):
	if character.currentArea == character.targetArea:
		changeToNextArea()
	
	var lowestDist = checkLowestDistanceToTagger()
	if lowestDist > 35:
		wander_time = 0
	if wander_time > 0:
		wander_time -= delta
	else:
		if lowestDist <= 35 and sideLook == false:
			changeToSideArea()
#			print("Moving to other side for " + character.name)
		else:
			if sideLook == false:
				changeToNextArea()
#			print("Moving FORWARD for " + character.name + ", since lowestDist = " + str(lowestDist))
#			print("GOING TO THE SIDE? " + str(sideLook) + " towards " + character.targetArea.name)
			Transitioned.emit(self, "Forward")
		
func Physics_Update(_delta):
	if character:
		character.MoveTo(pos, 15)
