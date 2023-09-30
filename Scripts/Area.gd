extends Area2D
class_name Area

@export var next_area_from_home : Area
@export var side_area : Area
@export var next_area_returning : Area

@export var end_area : bool
@export var start_area : bool

var inside : Dictionary = {}

func Entered(person):
	print(person.name, " entered ", self.name)
	inside[person.name] = person
	
func Exited(person):
	print(person.name, " exited ", self.name)
	inside.erase(person.name)

@onready var collider : CollisionShape2D = get_node("CollisionShape2D")

func _ready():
	if not collider:
		push_error("ERROR: Area has no collision detection!")
	self.body_entered.connect(Entered)
	self.body_exited.connect(Exited)
