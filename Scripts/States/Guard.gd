extends State
class_name Guard

@export var character : CharacterBody2D
@onready var AreaHandler = get_node("/root/World/PlayingAreas")

@onready var middleLine = get_node("/root/World/Lines/MiddleLine")

var dir : Vector2
var pos : Vector2
var players : Array

@export var middleLineBool = false
var switchingLine = false

var RUNNNN = false

@export var currentTarget : CharacterBody2D

func getTarget():
	var possibleTargets : Array = []
	var distances : Dictionary = {}
	var lowestDist = 9999
	var lowestTarget = ""
	for i in players:
		if i.nextLine == character.currentLine:
			if possibleTargets.find(i) == -1:
				possibleTargets.append(i)
		else:
			distances.erase(i)
			possibleTargets.erase(i)
	for i in possibleTargets:
		distances[i.name] = i.distanceToNextLine
	
	for target in distances:
		if distances[target] <= lowestDist:
			lowestDist = distances[target]
			lowestTarget = target
	
	if lowestDist <= 10:
		RUNNNN = true
	else:
		RUNNNN = false
	
	for target in possibleTargets:
		if lowestTarget == target.name:
			return target

func getMidTarget():
	var distances : Dictionary = {}
	var lowestDist = 9999
	var lowestTarget = ""
	for i in players:
		if i.nextLine.name != "Line3" or i.Returning == false:
			distances[i.name] = i.distanceToMiddleLine
	
	for target in distances:
		if distances[target] <= lowestDist:
			lowestDist = distances[target]
			lowestTarget = target
	
	if lowestDist <= 10:
		RUNNNN = true
	else:
		RUNNNN = false
	
	for target in players:
		if lowestTarget == target.name:
			return target


func toggleMiddleLine():
	switchingLine = true
	character.ReachedTarget.connect(successfulSwitch)
	
func successfulSwitch():
	character.ReachedTarget.disconnect(successfulSwitch)
	if character.currentTeam == "Runners":
		print("WARNING: why is a runner switching to middle line? -------------------------")
	switchingLine = false
	
	character.global_position = Vector2(middleLine.global_position.x, character.currentLine.global_position.y)
	
	middleLineBool = not middleLineBool
	character.middleLine = not character.middleLine
	if middleLineBool == true:
		character.set_collision_layer(middleLine.get_collision_layer()+1)
		character.set_collision_mask(middleLine.get_collision_mask()+1)
	else:
		character.set_collision_layer(character.currentLine.get_collision_layer()+1)
		character.set_collision_mask(character.currentLine.get_collision_mask()+1)

func Enter():
	if not character:
		character = get_parent().get_parent()
	character.DisableAreaRays.emit(true)
	character.DisablePlayerRays.emit(true)

func Exit():
	if character.ReachedTarget.is_connected(successfulSwitch):
		character.ReachedTarget.disconnect(successfulSwitch)
	character.DisableAreaRays.emit(false)
	character.DisablePlayerRays.emit(false)

var spd
func Update(_delta):
	players = get_node("/root/World").RunnersOnField
	
	var backupTarget
	currentTarget = getTarget()
	if middleLineBool == true:
		backupTarget = currentTarget
		currentTarget = getMidTarget()
	
	character.targetPlayer = currentTarget
	
	if not switchingLine:
		if backupTarget:
			toggleMiddleLine()
			print("Returning to line")
		else: if getMidTarget() and not currentTarget and character.currentLine.name == "Line1":
			toggleMiddleLine()
			print("Switching to middle")
	
	if switchingLine == true:
		RUNNNN = true
		character.MoveTo(Vector2(middleLine.global_position.x, character.currentLine.global_position.y), spd)
	
	if RUNNNN:
		character.RunBool(true)
		spd = 90
	else:
		character.RunBool(false)
		spd = 50

func Physics_Update(_delta):
	if switchingLine == true:
		return
	if character:
		if currentTarget:
			var targetPos
			if middleLineBool == false:
				targetPos = Vector2(currentTarget.global_position.x, character.currentLine.global_position.y)
			else:
				targetPos = Vector2(character.currentLine.global_position.x, currentTarget.global_position.y)
			character.MoveTo(targetPos, spd)
		else:
			character.MoveTo(pos, 15)
	
