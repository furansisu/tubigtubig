extends CharacterBody2D

# Called when the node enters the scene tree for the first time.

@export var default_acc = 100
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

@onready var default_font = load("res://Resources/FONTS/november.tres")

## CONTEXT STEERING -------------------------------------------------------------------

var WEIGHTS = {
	"CharacterBody2D": 10,
	"TileMap": 1.25,
	"Area2D": 5
}

@export var num_rays = 16

var ray_length = 15
var ray_directions = []
var interest = []
var danger = []

var InterestDirWeights = {}
var DangerDirWeights = {}

# [DIRECTION, POSITION, WEIGHT]

var debug_dirs = []
var colors = []
var prefDir = Vector2.ZERO

func getDanger():
	var space_state = get_world_2d().direct_space_state
	for i in num_rays:
		var query = PhysicsRayQueryParameters2D.create(position, position+ray_directions[i].rotated(rotation) * ray_length, 1, [self])
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		
		if result:
			DangerDirWeights[i] = ([ray_directions[i], result.position, getWeight(result.collider.get_class())])
			#danger[i] = clamp(1 - (position.distance_to(result.position) / ray_length),0,1)
			
		else:
			DangerDirWeights.erase(i)
			#danger[i] = 0
	
	for i in num_rays:
		var all = 0
		for j in DangerDirWeights:
			var d = ray_directions[i].dot(DangerDirWeights[j][0]) * clamp(1 - (position.distance_to(DangerDirWeights[j][1]) / ray_length),0,1) * DangerDirWeights[j][2]
			all += d
		all = clamp(all, 0, 1)
		danger[i] = max(0, all)
		colors[i] = Color.RED if danger[i] > 0 else Color.YELLOW_GREEN

func getInterest():
	var dir = position.direction_to(target_position)
	for i in num_rays:
		var d = ray_directions[i].dot(dir)
		#var d = 1 - abs(ray_directions[i].dot(dir) - 0.17)
		var opp = getOpposite(i)
		if danger[opp]:
			d = max(d, danger[opp] * 0.25)
			#d = max(d, 1 - abs(ray_directions[i].dot(-dir) - 0.5))
			pass
		interest[i] = max(0, d)
	queue_redraw()

var prevMaxInterests : Array = []
func chooseDir():
	prefDir = Vector2.ZERO
	for i in num_rays:
		interest[i] = interest[i] - danger[i]
		#prefDir += ray_directions[i] * interest[i]
		
		# DEBUG
		debug_dirs[i*2] = Vector2.ZERO
		debug_dirs[i*2+1] = ray_directions[i] * ray_length
		if interest[i] > 0:
			debug_dirs[i*2+1] *= interest[i]
			colors[i] = Color.YELLOW_GREEN
		else:
			debug_dirs[i*2+1] *= abs(interest[i])
			colors[i] = Color.RED
		# DEBUG
		
	var indexes = findAll(interest, interest.max())
	var index
	if prevMaxInterests.is_empty():
		prevMaxInterests = savePrevMax(interest, indexes)
	print("GETTING ALL MAX INTERESTS AND COMPARING WITH CURRENT VELOCITY")
	var minimum = 100
	var minIndex = 0
	for i in indexes:
		var magnitude = (ray_directions[i] - velocity.normalized()).length()
		if magnitude < 1:
			index = i
		if magnitude < minimum:
			minimum = magnitude
			minIndex = i
		print(i, " magnitude: ", magnitude)
	print("CHOSEN: ", index)
	if not index:
		index = minIndex
	print(indexes)
	prefDir = ray_directions[index]
	prevMaxInterests = savePrevMax(interest, indexes)

func savePrevMax(array: Array, indexes: Array):
	var newArray = []
	for i in indexes:
		newArray.append([array[i],i])
	return newArray

func getWeight(collider):
	var result = WEIGHTS.get(collider)
	return result if result else 0.5

func getOpposite(i):
	if i < num_rays / 2:
		return i + (num_rays / 2)
	else:
		return i - (num_rays / 2)

var debugText : Array = []
# [["TEXT", Color, Vector2, Collider], ["COLLIDE", Color, Vector2, TileMap]]

func drawText(i):
	var size = 5
	draw_string(default_font, i[2] - self.global_position - Vector2(size/2,0), i[0], HORIZONTAL_ALIGNMENT_LEFT, -1, size, i[1])
	await get_tree().create_timer(1).timeout
	debugText.erase(i)

func _draw():
	draw_line(Vector2.ZERO, Vector2.ZERO + prefDir.rotated(rotation) * 50, Color.GREEN_YELLOW, 2)
	draw_multiline_colors(debug_dirs, colors, 0.75)
	for i in debugText:
		drawText(i)

## -----------------------------------------------------------------------------------

func _ready():
	ray_directions.resize(num_rays)
	interest.resize(num_rays)
	danger.resize(num_rays)
	debug_dirs.resize(num_rays*2)
	colors.resize(num_rays)
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		ray_directions[i] = Vector2.RIGHT.rotated(angle)
		debug_dirs[i*2] = Vector2.ZERO
		debug_dirs[i*2+1] = ray_directions[i] * ray_length
	
	Marker = get_node("../../Marker")

# OTHER --------------------------------------------------------------------------------

func findAll(array : Array, value):
	var indexes = []
	var index = 0
	for i in array:
		if abs(i - value) <= 0.1:
			indexes.append(index)
		index += 1
	return indexes

# OTHER --------------------------------------------------------------------------------

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
	getDanger()
	chooseDir()
	
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var alreadyCollided = false
		for j in debugText:
			if j[3] and j[3] == collision.get_collider():
				alreadyCollided = true
				break
		if not alreadyCollided:
			var newCollision = ["collide", Color.RED, collision.get_position(), collision.get_collider()]
			debugText.append(newCollision)
		
	
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
	
	var desired_velocity = direction * maxspeed
	velocity = velocity.lerp(desired_velocity, 0.125)
	#velocity += direction * acc * delta
	#velocity -= velocity * friction * delta
		
	# run test
	if Input.is_action_pressed("run"):
		maxspeed = default_acc * 1.5
	else:
		maxspeed = default_acc
	
	# actual moving
	
	move_and_slide()
	
