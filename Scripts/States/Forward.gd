extends State
class_name Forward

@export var character : CharacterBody2D
@onready var AreaHandler = get_node("/root/World/PlayingAreas")

var dir : Vector2
var pos : Vector2
var wander_time : float

var players: Array

func randomize_wander():
	dir = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1,2)
	
func random_newpos():
	pos = Vector2(randi_range(-100,100), randi_range(-100,100)) + character.global_position
	wander_time = randf_range(6,10)

func random_pos_area():
	if AreaHandler.checkIfInArea(character):
#		print(character.name + " CHARACTER ALREADY REACHED TARGET AREA! " + character.targetArea.name + ", current: " + character.currentArea.name)
		Transitioned.emit(self, "Strafe")
	pos = AreaHandler.random_pos(character.targetArea)
	
func checkLowestDistanceToTagger():
	var distances : Dictionary = {}
	var lowestDist = 9999
	
	if character.movingToSide == true:
		for i in players:
			if i.middleLine == true:
				return i.global_position.distance_to(character.global_position)
		return 9999
	
	for i in players:
		distances[i.name] = i.global_position.distance_to(character.global_position)
	
	for target in distances:
		if distances[target] <= lowestDist:
			lowestDist = distances[target]
	
	character.distanceToClosestTagger = lowestDist
	return lowestDist

func Enter():
	players = get_node("/root/World").Taggers
	if not character:
		character = get_parent().get_parent()
	random_pos_area()
	character.RunBool(true)
	character.ReachedTarget.connect(random_pos_area)
	character.DisableAreaRays.emit(true)
	
	

func Exit():
	character.DisableAreaRays.emit(false)
	character.RunBool(false)
	character.ReachedTarget.disconnect(random_pos_area)
	
func Update(_delta):
	var lowestDist = checkLowestDistanceToTagger()
	if lowestDist <= 25:
		character.targetArea = character.currentArea
		Transitioned.emit(self, "DangerAvoid")
		
func Physics_Update(_delta):
	if character:
		character.MoveTo(pos, 50)
