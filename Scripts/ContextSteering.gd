extends Node
var default_font = load("res://Resources/FONTS/november.tres")

# ------------------------ V A R I A B L E S ------------------------------------------
# IMPORTANT SETTINGS HERE

var debug = true

var WEIGHTS = {
	"CharacterBody2D": 15,
	"TileMap": 2,
	"Area2D": 10
}

var num_rays = 16.0
var ray_length = 15

# ------------------------
# IMPORTANT ARRAYS HERE

var rays = []
# contains all ray direction vectors around a character. Number is based on num_rays and is set up in _ready function

var interest = []
var danger = []

# both interest and danger arrays correspond to a direction in the rays array (they share the same index)

var InterestDirWeights = {}
var DangerDirWeights = {}
# currently detected interest directions and danger directions. These are vital in calculating the
# 	interest and danger arrays.
# [direction, result_position, weight_of_detected_object]

var collisions = {}
# {RAY_INDEX : collision_object}

var colors = []
# holds colors for the lines in debug

# ------------------------------------------------------------------------------------
# MAIN FUNCTIONS
# meat of context steering behavior
# ------------------------------------------------------------------------------------
@export var exceptions : Array
var line
var players
var character : CharacterBody2D
var border
# ------------------------------------------------------------------------------
func setup(newcharacter : CharacterBody2D):
	
	# EXCEPTIONS
	exceptions = get_descendants(newcharacter.get_node("/root/World/PlayingAreas"))
	# ------------------------------------------------------------------------------
	line = newcharacter.get_node("/root/World/LineCollision")
	players = newcharacter.get_node("/root/World/Players").get_children()
	border = get_descendants(newcharacter.get_node("/root/World/SideBorder"))
	character = newcharacter
	# ------------------------------------------------------------------------------
	exceptions.append(character)
	exceptions.append(character.get_node("/root/World/MiddleLineSwitch"))
	# ------------------------------------------------------------------------------
	
	rays.resize(num_rays)
	interest.resize(num_rays)
	danger.resize(num_rays)
	debug_dirs.resize(num_rays*2)
	colors.resize(num_rays)
	
	for i in num_rays:
		var angle = i * 2 * PI / num_rays
		rays[i] = Vector2.RIGHT.rotated(angle)
		debug_dirs[i*2] = Vector2.ZERO
		debug_dirs[i*2+1] = rays[i] * ray_length
	character.DisableAreaRays.connect(disableRays)
	character.DisablePlayerRays.connect(disablePlayerRays)
	character.DisableBorderRays.connect(disableBorder)
# Sets up context steering for a character.
# Resizes and sets up all needed arrays and creates all the directions for raycasting around a character and
# 	saves them into the rays array.

func reset():
	disableRays(false)
	disablePlayerRays(false)
	disableBorder(false)

# --------------------------------------
var prevMaxInterests : Array = []
func chooseDir():
	getInterest()
	getDanger()
	debugCollision()
	for i in num_rays:
		interest[i] = interest[i] - danger[i]
		#prefDir += ray_directions[i] * interest[i]
		
		# DEBUG
		debug_dirs[i*2] = Vector2.ZERO
		debug_dirs[i*2+1] = rays[i] * ray_length
		if interest[i] > 0:
			debug_dirs[i*2+1] *= interest[i]
			colors[i] = Color.YELLOW_GREEN
		else:
			debug_dirs[i*2+1] *= abs(interest[i])
			colors[i] = Color.RED
		# DEBUG
		
	var indexes = findAllHighest(interest)
	var index
	if prevMaxInterests.is_empty():
		prevMaxInterests = savePrevMax(interest, indexes)
	#print("GETTING ALL MAX INTERESTS AND COMPARING WITH CURRENT VELOCITY")
	var minimum = 100
	var minIndex = 0
	for i in indexes:
		# HYSTERESIS: lag on direction change. For jitter problems
		var magnitude = (rays[i] - character.velocity.normalized()).length()
		if magnitude < 0.25:
			index = i
		if magnitude < minimum:
			minimum = magnitude
			minIndex = i
		#print(i, " magnitude: ", magnitude)
	#print("CHOSEN: ", index)
	if not index:
		index = minIndex
	#print(indexes)
	colors[index] = Color.GREEN
	var prefDir = rays[index]
	prevMaxInterests = savePrevMax(interest, indexes)
	return prefDir

# --------------------------------------

func getDanger():
	var space_state = character.get_world_2d().direct_space_state
	
	# FIRST LOOP: Raycast and detect any objects within range.
	# 	For each ray with a result, save the direction into DangerDirWeights
	for i in num_rays:
		var query = PhysicsRayQueryParameters2D.create(character.position, character.position+rays[i].rotated(character.rotation) * ray_length, 1, exceptions)
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		if result:
			DangerDirWeights[i] = ([rays[i], result.position, getWeight(result.collider.get_class())])
			collisions[i] = result
		else:
			collisions.erase(i)
			DangerDirWeights.erase(i)
			
	# SECOND LOOP: For each ray direction, calculate the danger weight based on each DangerDirWeight.
	# 	Uses dot product for how far the ray is to the direction and is multiplied by how far the character is to
	# 	the object.
	for i in num_rays:
		var all = 0
		for j in DangerDirWeights:
			var distanceMagnitude = (10/(character.position.distance_to(DangerDirWeights[j][1]))**2)
			var d = rays[i].dot(DangerDirWeights[j][0]) * clamp(distanceMagnitude,0,1) * DangerDirWeights[j][2]
			all += d
		all = clamp(all, 0, 1)
		danger[i] = max(0, all)
		colors[i] = Color.RED if danger[i] > 0 else Color.YELLOW_GREEN

# --------------------------------------
func getInterest():
	var dir = character.position.direction_to(character.target_position)
	for i in num_rays:
		var d
		if character.CSBShape == 'default':
			d = rays[i].dot(dir)
		if character.CSBShape == 'side':
			d = 1 - abs(rays[i].dot(dir) - 0.2)
		var opp = getOpposite(i)
		if danger[opp]:
			d = max(d, danger[opp] * 0.25)
			#d = max(d, 1 - abs(ray_directions[i].dot(-dir) - 0.5))
			pass
		interest[i] = max(0, d)
	character.queue_redraw()

# --------------------------------------
func disablePlayerRays(disableBool : bool):
#	print("Disabling player CSB detection for ", character.name, ": ", disableBool)
	if disableBool == true:
		exceptions.append_array(players)
	else:
		for i in players:
			exceptions.erase(i)

func disableRays(disableBool : bool):
	# print("Disabling line CSB detection for ", character.name, ": ", disableBool)
	if disableBool == true:
		exceptions.append(line)
	else:
		exceptions.erase(line)
	
func disableBorder(disableBool : bool):
#	print("Disabling border CSB detection for ", character.name, ": ", disableBool)
	if disableBool == true:
		exceptions.append_array(border)
	else:
		for i in border:
			exceptions.erase(i)

# ------------------------------------------------------------------------------------
# DEBUG FUNCTIONS
# will only work if debug is set to true. Shows raycasts and collisions
# ------------------------------------------------------------------------------------

var debugText : Array = []
# [["TEXT", Color, Vector2, Collider], ["COLLIDE", Color, Vector2, TileMap]]

var debug_dirs : Array = []
# [DIRECTION, POSITION, WEIGHT]

func draw():
	if not debug:
		return
	#character.draw_line(Vector2.ZERO, Vector2.ZERO + character.prefDir.rotated(character.rotation) * 50, Color.GREEN_YELLOW, 2)
	character.draw_multiline_colors(debug_dirs, colors, 0.75)
	var size = 5.0
	var string = ""
	if character.currentTeam == "Runners":
		if not character.targetArea:
			string = "NONE" + " " + str(character.distanceToClosestTagger)
		else:
			string = character.targetArea.name + " " + str(character.distanceToClosestTagger)
	if character.currentTeam == "Taggers":
		if character.targetPlayer:
			string = character.targetPlayer.name
		else:
			string = "NONE"
	var stateString = "NONE"
	var stateMachine = character.get_node("StateMachine")
	if stateMachine and stateMachine.current_state:
		stateString = stateMachine.current_state.name
	character.draw_string(default_font, Vector2(-23,-15), "TARGET: " + string + ", TEAM: " + str(character.currentTeam) + ", STATE: " + stateString, HORIZONTAL_ALIGNMENT_CENTER, -1, size)
	# 166 - 167: DRAWING THE CONTEXT STEERING INTEREST AND DANGER
	if character.target_position and character.MovingToPoint: #WHERE CHARACTER IS INTERESTED TO MOVE TO
		character.draw_circle(character.target_position - character.global_position, 3, Color.CHARTREUSE)
	for i in collisions: #COLLISIONS WITH RAYCASTING
		character.draw_circle(collisions[i].position - character.global_position,1, Color.RED)
	for i in debugText: #TEXT
		character.draw_string(default_font, i[2] - character.global_position - Vector2(size/2,0), i[0], HORIZONTAL_ALIGNMENT_LEFT, -1, size, i[1])
		var newThread = Thread.new()
		newThread.start(func wait():
			await character.get_tree().create_timer(1).timeout
			debugText.erase(i), Thread.PRIORITY_HIGH)
		newThread.wait_to_finish()
		

func debugCollision():
	for i in character.get_slide_collision_count():
		var collision = character.get_slide_collision(i)
		var alreadyCollided = false
		if collision.get_collider().is_class("StaticBody2D"):
			alreadyCollided = true
		for j in debugText:
			if j[3] and j[3] == collision.get_collider():
				alreadyCollided = true
				break
		if not alreadyCollided:
			var newCollision = ["collide", Color.RED, collision.get_position(), collision.get_collider()]
			debugText.append(newCollision)
		
# ------------------------------------------------------------------------------------
# MINI FUNCTIONS
# these functions do specific tasks for other functions
# ------------------------------------------------------------------------------------

func savePrevMax(array: Array, indexes: Array):
	var newArray = []
	for i in indexes:
		newArray.append([array[i],i])
	return newArray

# Returns an array containing the previous frame's max (highest) interest directions and indexes.
# [direction : Vector2, index_in_rays_array : int]

# --------------------------------------
var threshold = 0.1
func findAllHighest(array : Array):
	var maxvalue = array.max()
	var indexes = []
	var index = 0
	for i in array:
		if abs(i - maxvalue) <= threshold:
			indexes.append(index)
		index += 1
	return indexes

# Loops through an array and returns an array holding the highest values within a threshold.

# --------------------------------------
func getWeight(collider):
	var result = WEIGHTS.get(collider)
	return result if result else 0.5

# Returns the weight of a detected object from a raycast. Weight is how dangerous and repellant an object is.
# Refer to WEIGHTS dictionary.

# --------------------------------------
func getOpposite(i):
	if i < num_rays / 2:
		return i + (num_rays / 2)
	else:
		return i - (num_rays / 2)

# Given the index of a vector in the rays array, returns the index of the opposing vector.

# --------------------------------------
func get_descendants(in_node,arr:=[]):
	arr.push_back(in_node)
	for child in in_node.get_children():
		arr = get_descendants(child,arr)
	return arr
	
# Get all descendants of a node.
