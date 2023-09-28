extends CharacterBody2D
const contextsteeringscript = preload("res://Scripts/ContextSteering.gd")
@onready var CSB = contextsteeringscript.new()

# ------------------------ V A R I A B L E S ------------------------------------------

@export var maxspd = 50
var default_acc = maxspd
@export var selection = 0

var direction = Vector2.ZERO
@export var target_position = position
@export var MovingTo = false

var prefDir = Vector2.ZERO

# ------------------------------------------------------------------------------------

signal ReachedTarget
@onready var Marker = get_node("../../Marker")
var Moving = false
var spd = maxspd

func MoveTo(Position: Vector2, StopMoving, newspd):
	Moving = StopMoving
	Marker.position = Position
	target_position = Position
	SetNewSpd(newspd)

func Move(newDir, newspd):
	direction = newDir
	SetNewSpd(newspd)

func SetNewSpd(newspd):
	if newspd and newspd < maxspd:
		spd = newspd
	else:
		spd = maxspd

# ------------------------------------------------------------------------------------

func _draw():
	CSB._draw()

func _ready():
	CSB.setup(self)

func _physics_process(_delta):
	prefDir = CSB.chooseDir()
	
	if Moving:
		if position.distance_to(target_position) < 5:
			target_position = position
			print("Reached target")
			ReachedTarget.emit()
			Moving = false
		direction = prefDir
	
	# animation handling
	if (direction != Vector2.ZERO and (velocity > Vector2.ZERO or velocity < Vector2.ZERO)):
		if Input.is_action_pressed("run"):
			$AnimationPlayer.play("Run")
		else:
			$AnimationPlayer.play("WalkRight")
		#if direction.x < 0:
		if (position - target_position).x > 0:
			$Sprite2D.flip_h = true
		#if direction.x > 0:
		if (position - target_position).x < 0:
			$Sprite2D.flip_h = false
	else:
		$AnimationPlayer.play("Idle")
	
	var desired_velocity = direction * spd
	velocity = velocity.lerp(desired_velocity, 0.15)
		
	# run test
	if Input.is_action_pressed("run"):
		spd = default_acc * 1.5
	else:
		spd = default_acc
	
	move_and_slide()
	
