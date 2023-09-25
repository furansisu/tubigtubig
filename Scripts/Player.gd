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

## CONTEXT STEERING -------------------------------------------------------------------

@export var num_rays = 64

var ray_length = 25
var ray_directions = []
var interest = []
var danger = []

var debug_dirs = []
var debug_danger = []
var prefDir = Vector2.ZERO

func debugRays():
	var space_state = get_world_2d().direct_space_state
	for i in num_rays:
		var query = PhysicsRayQueryParameters2D.create(position, position+ray_directions[i].rotated(rotation) * ray_length, 1, [self])
		var result = space_state.intersect_ray(query)
		danger[i] = 1 if result else 0
		
		debug_dirs[i*2] = Vector2.ZERO
		debug_dirs[i*2+1] = ray_directions[i] * ray_length * interest[i]
		
		debug_danger[i*2] = Vector2.ZERO
		debug_danger[i*2+1] = ray_directions[i] * ray_length * danger[i]

func getInterest():
	var dir = position.direction_to(target_position)
	for i in num_rays:
		var d = ray_directions[i].rotated(rotation).dot(dir)
		interest[i] = max(0, d)
	queue_redraw()
		
func chooseDir():
	prefDir = Vector2.ZERO
	for i in num_rays:
		interest[i] = clamp(interest[i] - danger[i], 0, 1)
		prefDir += ray_directions[i] * interest[i]
	prefDir = prefDir.normalized()
	print(prefDir)
	

func _draw():
	draw_line(Vector2.ZERO, Vector2.ZERO + prefDir.rotated(rotation) * 50, Color.GREEN_YELLOW, 2)
	draw_multiline(debug_dirs, Color.YELLOW_GREEN, 0.75)
	draw_multiline(debug_danger, Color.RED, 1)

## -----------------------------------------------------------------------------------

func _ready():
	ray_directions.resize(num_rays)
	interest.resize(num_rays)
	danger.resize(num_rays)
	debug_dirs.resize(num_rays*2)
	debug_danger.resize(num_rays*2)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
		debug_dirs[i*2] = Vector2.ZERO
		debug_dirs[i*2+1] = ray_directions[i] * ray_length
	
	Marker = get_node("../../Marker")

# UNUSED --------------------------------------------------------------------------------

func force():
	pass

# UNUSED --------------------------------------------------------------------------------

func MoveTo(Position: Vector2, StopMoving):
	Moving = StopMoving
	Marker.position = Position
	target_position = Position

func ChangeMotion(newDir):
	direction = newDir
	if newDir.length() > .1:
		Moving = false

func _physics_process(delta):
	#force()
	getInterest()
	debugRays()
	chooseDir()
	
	if Moving:
		if position.distance_to(target_position) < 5:
			target_position = position
			print("Reached target")
			Moving = false
		direction = prefDir
	
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
	
