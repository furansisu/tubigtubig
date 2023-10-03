extends State
class_name Strafe

@export var character : CharacterBody2D
@onready var AreaHandler = get_node("/root/World/PlayingAreas")

var dir : Vector2
var pos : Vector2
var wander_time : float

func randomize_wander():
	dir = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1,2)
	
func random_newpos():
	pos = Vector2(randi_range(-100,100), randi_range(-100,100)) + character.global_position
	wander_time = randf_range(6,10)
	
func random_pos_area():
	pos = AreaHandler.random_pos(character.targetArea)
	wander_time = randf_range(6,10)
	
func changeToNextArea():
	character.targetArea = AreaHandler.getNextAreaOfCharacter(character)
	
func checkInArea():
	pass

func Enter():
	if not character:
		character = get_parent().get_parent()
	if not AreaHandler.checkIfInArea(character):
			Transitioned.emit(self, "Forward")
	random_pos_area()
	changeToNextArea()
	character.ReachedTarget.connect(random_pos_area)

func Exit():
	character.ReachedTarget.disconnect(random_pos_area)
	
func Update(delta):
	if wander_time > 0:
		wander_time -= delta
	else:
		changeToNextArea()
		Transitioned.emit(self, "Forward")
		
func Physics_Update(_delta):
	if character:
		character.MoveTo(pos, 15)
