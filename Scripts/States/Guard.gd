extends State
class_name Guard

@export var character : CharacterBody2D
@onready var AreaHandler = get_node("/root/World/PlayingAreas")

@onready var middleLine = get_node("/root/World/Lines/MiddleLine")

var dir : Vector2
var pos : Vector2
var players : Array

@export var alertDistance = 10
@export var middleLineBool = false
var switchingLine = false

var RUNNNN = false

@export var currentTarget : CharacterBody2D

func getTarget():
    var possibleTargets : Array = []
    var distances : Dictionary = {}
    var lowestDist = 9999
    var lowestTarget = null
    for i in players:
        if i.nextLine == character.currentLine:
            if possibleTargets.find(i) == -1:
                possibleTargets.append(i)
    for i in possibleTargets:
        distances[i.name] = i.distanceToNextLine
    
    for target in distances:
        if distances[target] <= lowestDist:
            lowestDist = distances[target]
            lowestTarget = target
    
    character.lowestDistDebug = lowestDist
    
    if character.lowestDistDebug <= alertDistance:
        character.running = true
    else:
        character.running = false
    
    character.lowestDistDebug = lowestDist
    
    for target in possibleTargets:
        if lowestTarget == target.name:
            return target
    
    if possibleTargets.is_empty() and character.currentLine.name != "Line1":
        for player in players:
            var distance = abs(player.global_position.y - character.currentLine.global_position.y)
            if distance <= lowestDist:
                lowestDist = distance
                lowestTarget = player
        character.lowestDistDebug = lowestDist
        return lowestTarget

func getMidTarget():
    var distances : Dictionary = {}
    var lowestDist = 9999
    var lowestTarget = ""
    for i in players:
        if i.nextLine.name != "Line3" or i.Returning == false:
            distances[i.name] = i.distanceToMiddleLine
    
    for target in distances:
        if distances[target] <= lowestDist:
            lowestDist = distances[target]
            lowestTarget = target
    
    if lowestDist <= alertDistance:
        character.running = true
    else:
        character.running = false
    
    character.lowestDistDebug = lowestDist
    
    for target in players:
        if lowestTarget == target.name:
            return target


func toggleMiddleLine():
    switchingLine = true
    character.ReachedTarget.connect(successfulSwitch)
    
func successfulSwitch():
    character.ReachedTarget.disconnect(successfulSwitch)
    if character.currentTeam == "Runners":
        print("WARNING: why is a runner switching to middle line? -------------------------")
    switchingLine = false
    
    character.global_position = Vector2(middleLine.global_position.x, character.currentLine.global_position.y)
    
    middleLineBool = not middleLineBool
    character.middleLine = not character.middleLine
    if middleLineBool == true:
        character.set_collision_layer(middleLine.get_collision_layer()+1)
        character.set_collision_mask(middleLine.get_collision_mask()+1)
    else:
        character.set_collision_layer(character.currentLine.get_collision_layer()+1)
        character.set_collision_mask(character.currentLine.get_collision_mask()+1)

func Enter():
    if not character:
        character = get_parent().get_parent()
    character.DisableAreaRays.emit(true)
    character.DisablePlayerRays.emit(true)

func Exit():
    if character.ReachedTarget.is_connected(successfulSwitch):
        character.ReachedTarget.disconnect(successfulSwitch)
    character.DisableAreaRays.emit(false)
    character.DisablePlayerRays.emit(false)

var spd
func Update(_delta):
    players = get_node("/root/World").RunnersOnField
    
    var backupTarget
    currentTarget = getTarget()
    if middleLineBool == true:
        backupTarget = currentTarget
        currentTarget = getMidTarget()
    
    character.targetPlayer = currentTarget
    
    if not switchingLine:
        if backupTarget:
            toggleMiddleLine()
            print("Returning to line")
        else: if not currentTarget and character.currentLine.name == "Line1":
            if getMidTarget():
                toggleMiddleLine()
                print("Switching to middle")
            elif not players.is_empty():
                currentTarget = players[0]
                toggleMiddleLine()
                print("Returning to line")
    
    if switchingLine == true:
        character.running = true
        character.MoveTo(Vector2(middleLine.global_position.x, character.currentLine.global_position.y), spd)

func Physics_Update(_delta):
    if switchingLine == true:
        return
    if character:
        if currentTarget:
            var targetPos
            if middleLineBool == false:
                targetPos = Vector2(currentTarget.global_position.x, character.currentLine.global_position.y)
            else:
                targetPos = Vector2(character.currentLine.global_position.x, currentTarget.global_position.y)
            character.MoveTo(targetPos, spd)
        else:
            character.MoveTo(pos, 15)
    
    if character.lowestDistDebug > alertDistance and character.running == true:
#		push_error("WHY  THE FUCK")
        character.running = false
    elif character.lowestDistDebug < alertDistance and character.running == false:
#		push_error("GET EMN")
        character.running = true
#	print(str(character.running) + " | " + character.name + ", " + str(character.lowestDistDebug))
    
    if character.running == true:
        character.SetNewSpd(90)
    else:
        character.SetNewSpd(50)
