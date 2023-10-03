extends Node

var areas : Array = []
var start : Array = []
var end : Array = []

func random_pos(area):
	if not area: push_error("No area given"); return
	var collisionArea : CollisionShape2D = area.get_node("CollisionShape2D")
	var size = collisionArea.shape.extents
	var pos = Vector2(randi_range(0,size.x),randi_range(0,size.y)) + collisionArea.global_position - size/2
	return pos

func _ready():
	areas = get_children()
	for i in areas:
		if i.start_area:
			start.append(i)
		if i.end_area:
			end.append(i)
	print("Areas set!")

func checkIfInArea(character: CharacterBody2D):
	var index = getIndexOfArea(character)
	var peopleInsideArea = areas[index].inside
	for i in peopleInsideArea:
		if peopleInsideArea[i] == character:
			return true
	return false

func setStartingArea():
	print("Returning a starting area from ", start)
	return start.pick_random()

func getNextAreaOfCharacter(character):
	var index = getIndexOfArea(character)
	var area = areas[index]
	var returnArea
	if character.Returning:
		returnArea = area.next_area_returning
	else:
		returnArea = area.next_area_from_home
	if not returnArea:
		returnArea = area
	return returnArea

func getIndexOfArea(character):
	var targetArea = character.targetArea
	if not targetArea:
		push_error('Character ', character.name, 'does not have a target area')
		return
	return areas.find(targetArea)