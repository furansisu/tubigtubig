extends State
class_name Guard

@export var character : CharacterBody2D
@onready var AreaHandler = get_node("/root/World/PlayingAreas")

var dir : Vector2
var pos : Vector2
var players : Array
var possibleTargets : Array
var distances : Dictionary = {}

@export var currentTarget : CharacterBody2D

func getTarget():
	for i in players:
		if i.nextLine == character.currentLine:
			if possibleTargets.find(i) == -1:
				possibleTargets.append(i)
		else:
			print(character.name + ": " + i.name + "'s nextLine is not " + character.currentLine.name)
			distances.erase(i)
			possibleTargets.erase(i)
	for i in possibleTargets:
		distances[i.name] = i.distanceToNextLine
	var lowestDist = 9999
	var lowestTarget = ""
	for target in distances:
		if distances[target] <= lowestDist:
			lowestDist = distances[target]
			lowestTarget = target
			
	for target in possibleTargets:
		if lowestTarget == target.name:
			return target

func Enter():
	if not character:
		character = get_parent().get_parent()
	players = get_node("/root/World").Runners
	character.DisableAreaRays.emit(true)

func Exit():
	character.DisableAreaRays.emit(false)
	
func Update(_delta):
	currentTarget = getTarget()
		
func Physics_Update(_delta):
	if character:
		if currentTarget:
			character.MoveTo(currentTarget.global_position, 50)
		else:
			character.MoveTo(pos, 15)
