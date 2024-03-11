extends State
class_name DangerAvoid

@export var character : CharacterBody2D
@onready var AreaHandler = get_node("/root/World/PlayingAreas")

var dir : Vector2
var pos : Vector2
var wander_time : float

var players: Array

func random_pos_area():
    pos = AreaHandler.random_pos(character.targetArea)
    wander_time = randf_range(6,10)

var avoidTarget
func checkLowestDistanceToTagger():
    var distances : Dictionary = {}
    var lowestDist = 9999
    for i in players:
        distances[i.name] = i.global_position.distance_to(character.global_position)
    
    var takeNote
    for target in distances:
        if distances[target] <= lowestDist:
            lowestDist = distances[target]
            takeNote = target
    for i in players: if i.name == takeNote: avoidTarget = i
    
    character.distanceToClosestTagger = lowestDist
    return lowestDist

func Enter():
    players = get_node("/root/World").Taggers
    if not character:
        character = get_parent().get_parent()
    character.running = true
    character.DisableAreaRays.emit(true)

func Exit():
    character.DisableAreaRays.emit(false)
    character.running = false
    
var direction
func Update(_delta):
    var lowestDist = checkLowestDistanceToTagger()
    pos = character.global_position + (character.global_position - avoidTarget.global_position).normalized() * 40
    if lowestDist >= 25:
        
        character.targetArea = character.currentArea
        Transitioned.emit(self, "Strafe")
        
func Physics_Update(_delta):
    if character:
        character.MoveTo(pos, 50)
