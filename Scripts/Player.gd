extends CharacterBody2D
const contextsteeringscript = preload("res://Scripts/ContextSteering.gd")
@onready var CSB = contextsteeringscript.new()

# ------------------------ V A R I A B L E S ------------------------------------------

@export var spd = 50
var defaultspd = spd
var lastspd = spd

@export var IsSelected = false

var direction = Vector2.ZERO
@export var target_position = position

var prefDir = Vector2.ZERO
var targetArea : Area
var targetPlayer : CharacterBody2D
var nextScoreArea : Array
var nextLine : StaticBody2D
@export var distanceToClosestTagger = 0
var middleLine = false
var movingToSide = false
@onready var middleLineNode = get_node("/root/World/Lines/MiddleLine")
@export var distanceToNextLine = 0
@export var distanceToMiddleLine = 0
@export var currentArea : Area
@onready var currentTeam = "Runner"
@export var teamNumber = 0
@export var currentLine : StaticBody2D

# ------------------------------------------------------------------------------------

signal setupReady
signal ReachedTarget
signal Selected
signal DisableAreaRays
signal DisablePlayerRays
var MovingToPoint = false
var running = false
var LookAtPoint : Vector2
var Returning = false

func MoveTo(Position: Vector2, newspd):
	MovingToPoint = true
	target_position = Position
	setLookAt(true, target_position)
	SetNewSpd(newspd)

func Move(newDir, newspd):
	direction = newDir
	if MovingToPoint == true:
		setLookAt(false, Vector2.ZERO)
		SetNewSpd(newspd)
	MovingToPoint = false

func SetNewSpd(newspd):
	if newspd == spd:
		return
	if newspd:
		spd = newspd
		lastspd = newspd
	else:
		spd = defaultspd
		lastspd = spd

func RunBool(newRunning):
	running = newRunning

func setLookAt(LookAtBool, point : Vector2):
	if LookAtBool == true:
		LookAtPoint = point
	else:
		LookAtPoint = Vector2.ZERO

# ------------------------------------------------------------------------------------

var CSBShape = 'default'
func _draw():
	CSB.draw()

func _ready():
	CSB.setup(self)
	Selected.connect(OnSelect)

func _physics_process(_delta):
	prefDir = CSB.chooseDir()
	
	if MovingToPoint:
		direction = prefDir
		if position.distance_to(target_position) < 10:
			target_position = position
			ReachedTarget.emit()
			MovingToPoint = false
			direction = Vector2.ZERO
	
	# animation handling
	if (direction != Vector2.ZERO and velocity != Vector2.ZERO):
		if running:
			$AnimationPlayer.play("Run")
		else:
			$AnimationPlayer.play("WalkRight")
		
		if LookAtPoint != Vector2.ZERO:
			if (position - LookAtPoint).x >= 0:
				$Sprite2D.flip_h = true
			else:
				$Sprite2D.flip_h = false
		else:
			if velocity.x >= 0:
				$Sprite2D.flip_h = false
			else:
				$Sprite2D.flip_h = true
		
	else:
		$AnimationPlayer.play("Idle")
	
	var desired_velocity = direction * spd
	velocity = velocity.lerp(desired_velocity, 0.15)
		
	# run test
	if running:
		spd = lastspd * 1.5
	else:
		spd = lastspd
	
	move_and_slide()
	
	distanceToMiddleLine = abs(global_position.x - middleLineNode.global_position.x)
	if nextLine:
		distanceToNextLine = abs(global_position.y - nextLine.global_position.y)
	
func OnSelect(selectedBool):
	IsSelected = selectedBool
