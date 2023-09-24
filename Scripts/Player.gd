extends CharacterBody2D

# Called when the node enters the scene tree for the first time.

@export var default_acc = 800
var acc = default_acc
@export var maxspeed = 100
@export var selection = 0
var friction = (acc/maxspeed)

var direction = Vector2.ZERO
@export var target_position = position
@export var MovingTo = false

var Marker
var Force
var Moving = false
var ray = RayCast2D.new()

func _ready():
	Marker = get_node("../../Marker")
	Force = get_node("../../Force")
	self.add_child(ray)
	print(Force.global_position)
	

func MoveTo(Position: Vector2, StopMoving):
	Moving = StopMoving
	Marker.position = Position
	target_position = Position
	
func force():
	ray.target_position = Force.global_position - self.global_position

func ChangeMotion(newDir):
	direction = newDir
	if newDir.length() > .1:
		Moving = false

func _physics_process(delta):
	force()
	if Moving:
		if position.distance_to(target_position) < 5:
			target_position = position
			print("Reached target")
			Moving = false
		direction = position.direction_to(target_position)
	
	# animation handling
	if (direction != Vector2.ZERO and (velocity > Vector2.ZERO or velocity < Vector2.ZERO)):
		if Input.is_action_pressed("run"):
			$AnimationPlayer.play("Run")
		else:
			$AnimationPlayer.play("WalkRight")
		if direction.x < 0:
			$Sprite2D.flip_h = true
		if direction.x > 0:
			$Sprite2D.flip_h = false
	else:
		$AnimationPlayer.play("Idle")
	
	velocity += direction * acc * delta
	velocity -= velocity * friction * delta
		
	# run test
	if Input.is_action_pressed("run"):
		acc = default_acc * 1.5
	else:
		acc = default_acc
	
	# actual moving
	
	move_and_slide()
	
