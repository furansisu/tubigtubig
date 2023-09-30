extends Node

var areas : Array = []
var start : Array = []
var end : Array = []

func random_pos(area):
	if not area: return
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
