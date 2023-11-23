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
			if not possibleTargets.find(i):
				possibleTargets.append(i)
		else:
			distances.erase(i)
			possibleTargets.erase(i)
	for i in possibleTargets:
		distances[i] = i.distanceToNextLine
	for i in distances:
		pass

func randomize_wander():
	dir = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	
func random_newpos():
	pos = Vector2(randi_range(-100,100), randi_range(-100,100)) + character.global_position
	
func random_pos_area():
	pos = AreaHandler.random_pos(character.targetArea)
	
func changeToNextArea():
	character.targetArea = AreaHandler.getNextAreaOfCharacter(character)
	
func checkInArea():
	pass

func Enter():
	if not character:
		character = get_parent().get_parent()
	players = get_node("/root/World").Runners

func Exit():
	pass
	
func Update(_delta):
	pass
		
func Physics_Update(_delta):
	if character:
		character.MoveTo(pos, 15)
