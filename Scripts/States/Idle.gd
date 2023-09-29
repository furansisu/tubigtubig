extends State
class_name Idle

@export var character : CharacterBody2D

var dir : Vector2
var pos : Vector2
var wander_time : float

func randomize_wander():
	dir = Vector2(randf_range(-1,1), randf_range(-1,1)).normalized()
	wander_time = randf_range(1,2)
	print("Moving randomly: ", dir)
	
func random_newpos():
	pos = Vector2(randi_range(-100,100), randi_range(-100,100)) + character.global_position
	wander_time = randf_range(6,10)
	print("Moving randomly for ", character.name, " ", pos)

func Enter():
	if not character:
		character = get_parent().get_parent()
	random_newpos()
	character.ReachedTarget.connect(random_newpos)

func Exit():
	character.ReachedTarget.disconnect(random_newpos)
	
func Update(delta):
	if wander_time > 0:
		wander_time -= delta
	else:
		random_newpos()
		
func Physics_Update(delta):
	if character:
		character.MoveTo(pos, 15)
