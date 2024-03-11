extends Area2D

func Entered(_person):
#	print("SOMEONE ENTERED")
    pass
    
func Exited(person):
#	print("SOMEONE EXITED")
    if person.currentTeam != "Taggers":
        return
    if person.global_position.y > self.global_position.y:
#		print(person.name + " is in ORIGINAL LINE")
        person.middleLine = false
    else:
#		print(person.name + " is in MIDDLE LINE")
        person.middleLine = true

@onready var collider : CollisionShape2D = get_node("CollisionShape2D")
# Called when the node enters the scene tree for the first time.
func _ready():
    if not collider:
        push_error("ERROR: Area has no collision detection!")
    body_entered.connect(Entered)
    body_exited.connect(Exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
    pass
