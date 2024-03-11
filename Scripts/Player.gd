extends CharacterBody2D
const contextsteeringscript = preload("res://Scripts/ContextSteering.gd")
const preloadedShader = preload("res://Characters/Outline.gdshader")
var default_font = load("res://Resources/FONTS/PixelEmulator-xq08.ttf")
@onready var CSB = contextsteeringscript.new()
@onready var sprite : Sprite2D = get_node("Sprite2D")

# ------------------------ V A R I A B L E S ------------------------------------------

@export var spd = 50
var defaultspd = spd
var lastspd = spd

@export var IsSelected = false

var direction = Vector2.ZERO
@export var target_position = position

var Caught
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
@onready var currentTeam = ""
@export var teamNumber = 0
@export var currentLine : StaticBody2D
@onready var StateMachine = get_node("StateMachine")
@onready var staminaBar : ProgressBar = get_node("StaminaBar")

var lowestDistDebug = 0

# ------------------------------------------------------------------------------------

signal setupReady
signal ReachedTarget
signal Selected

signal DisableAreaRays
signal DisablePlayerRays
signal DisableBorderRays

var MovingToPoint = false
var running = false
var canDash = true
var dashing = false
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

func setLookAt(LookAtBool, point : Vector2):
	if LookAtBool == true:
		LookAtPoint = point
	else:
		LookAtPoint = Vector2.ZERO

# ------------------------------------------------------------------------------------
var tagText = false
var tagPos = null
var CSBShape = 'default'
func _draw():
	CSB.draw()
	if tagText == true:
		draw_string(default_font, tagPos - global_position, "TAGGED!", HORIZONTAL_ALIGNMENT_CENTER, -1, 5, Color.ORANGE_RED)
		var newThread = Thread.new()
		newThread.start(func wait():
			await get_tree().create_timer(1).timeout
			tagText = false, Thread.PRIORITY_HIGH)
		newThread.wait_to_finish()
		
var outlineShader
func _ready():
	CSB.setup(self)
	Selected.connect(OnSelect)
	
	outlineShader = ShaderMaterial.new()
	outlineShader.set_shader(preloadedShader)

func _physics_process(_delta):
	prefDir = CSB.chooseDir()
	
	if MovingToPoint:
		direction = prefDir
		if position.distance_to(target_position) < 10:
			target_position = position
			ReachedTarget.emit()
			MovingToPoint = false
			direction = Vector2.ZERO
	
	if staminaBar.value <= 10:
		running = false
		spd = defaultspd * 0.5
	
	# animation handling
	if (direction != Vector2.ZERO and velocity != Vector2.ZERO):
		if running and staminaBar.value > 0:
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
	
	
	
	getCollisions()
	
	distanceToMiddleLine = abs(global_position.x - middleLineNode.global_position.x)
	if nextLine:
		distanceToNextLine = abs(global_position.y - nextLine.global_position.y)
	
	move_and_slide()

func dash():
    if staminaBar.value <= 30:
        var redFill = staminaBar.get_theme_stylebox("fill").duplicate()
        var redbgFill = staminaBar.get_theme_stylebox("background").duplicate()
        redFill.bg_color = Color.RED
        redbgFill.bg_color = Color.DARK_RED
        staminaBar.add_theme_stylebox_override("fill", redFill)
        staminaBar.add_theme_stylebox_override("background", redbgFill)
        await get_tree().create_timer(0.5).timeout
        staminaBar.remove_theme_stylebox_override("fill")
        staminaBar.remove_theme_stylebox_override("background")
        return
    if canDash:
        var desired_velocity = direction * 2000
        velocity = velocity.lerp(desired_velocity, 0.15)
        canDash = false
        dashing = true
        await get_tree().create_timer(1.0).timeout
        canDash = true
        dashing = false

func OnSelect(selectedBool):
	IsSelected = selectedBool
	if selectedBool == true:
		outlineShader.set_shader_parameter('color', Color.LAWN_GREEN)
		sprite.material = outlineShader
	else:
		sprite.material = null
	
func getCollisions():
	for i in self.get_slide_collision_count():
		var collision = self.get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_class("CharacterBody2D") and self.currentTeam == "Runners" and collider.currentTeam == "Taggers":
			get_node("/root/World").Caught.emit(self, collider, collision.get_position())
		if collider.is_class("CharacterBody2D") and self.currentTeam == "Taggers" and collider.currentTeam == "Runners":
			get_node("/root/World").Caught.emit(collider, self, collision.get_position())
			tagPos = collision.get_position()
			tagText = true
			queue_redraw()
		

# ------------------------------------------------------------------------------------
func reset():
	tagText = false
	nextScoreArea = []
	currentTeam = ""
	
	currentArea = null
	currentLine = null
	targetArea = null
	targetPlayer = null
	nextLine = null
	
	distanceToClosestTagger = 0
	distanceToNextLine = 0
	distanceToMiddleLine = 0
	
	direction = Vector2.ZERO
	target_position = position
	
	middleLine = false
	movingToSide = false
	Caught = false
	IsSelected = false
	MovingToPoint = false
	running = false
	Returning = false
	
	SetNewSpd(0)
	StateMachine.reset()
	CSB.reset()
# ------------------------------------------------------------------------------------
