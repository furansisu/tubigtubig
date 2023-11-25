extends State
class_name OutOfGame

@export var character : CharacterBody2D
@onready var AreaHandler = get_node("/root/World/PlayingAreas")

var dir : Vector2
var pos : Vector2
var wander_time : float

var players: Array

func random_pos_area():
	pos = AreaHandler.random_pos(get_node("/root/World/SideBorder/RestArea"))
	wander_time = randf_range(6,10)
	character.ReachedTarget.connect(disableSelf)
	
func disableSelf():
	Transitioned.emit(self, "Disable")

func Enter():
	if not character:
		character = get_parent().get_parent()
	character.RunBool(false)
	character.DisableAreaRays.emit(true)
	character.DisablePlayerRays.emit(true)
	character.DisableBorderRays.emit(true)
	character.set_collision_mask(0)
	character.set_collision_layer(2)
	print("Moving out of game..")
	random_pos_area()

func Exit():
	character.ReachedTarget.disconnect(disableSelf)
	
var wait = 1
func Update(delta):
	wait -= delta
	if wait <= 0:
		character.MoveTo(pos, 20)
		
func Physics_Update(_delta):
	pass
