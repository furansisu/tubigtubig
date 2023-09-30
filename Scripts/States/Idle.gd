extends State
class_name Idle

@export var character : CharacterBody2D

@onready var bottom : Area2D = get_node("/root/World/PlayingAreas/BottomArea")

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
	
func random_pos_area():
	var collisionArea : CollisionShape2D = bottom.get_node("CollisionShape2D")
	var size = collisionArea.shape.extents
	pos = Vector2(randi_range(0,size.x),randi_range(0,size.y)) + collisionArea.global_position - size/2
	wander_time = randf_range(4,6)
	print(character.name, " moving into ", bottom.name, ": ", pos)

func Enter():
	if not character:
		character = get_parent().get_parent()
	random_pos_area()
	character.ReachedTarget.connect(random_pos_area)

func Exit():
	character.ReachedTarget.disconnect(random_pos_area)
	
func Update(delta):
	if wander_time > 0:
		wander_time -= delta
	else:
		random_pos_area()
		
func Physics_Update(_delta):
	if character:
		character.MoveTo(pos, 15)
