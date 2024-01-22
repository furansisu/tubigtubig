extends Area2D
class_name Area

@onready var AreaHandler = get_node("/root/World/PlayingAreas")

@export var next_area_from_home : Area
@export var side_area : Area
@export var next_area_returning : Area

@export var next_line_from_home : StaticBody2D
@export var side_line : StaticBody2D
@export var next_line_returning : StaticBody2D

@export var end_area : bool
@export var start_area : bool

@export var nonGameArea : bool = false

var inside : Dictionary = {}
@onready var level = get_node("/root/World")

var entered_label

func Entered(person):
    if not person.is_class("CharacterBody2D"): return
#	print(person.name, " entered ", name)
    inside[person.name] = person
    person.currentArea = self
    if end_area:
        person.Returning = true
    if start_area:
        person.Returning = false
    
    if nonGameArea: return
    var scoreArea = false
    for i in person.nextScoreArea:
        if i == self:
            scoreArea = true
    if person.currentTeam == "Runners" and scoreArea:
        level.Scored.emit(person)
        # print(person.name + " scored! " + self.name)
        var nextArea = AreaHandler.getNextAreaOfCharacter(person)
        person.nextScoreArea = [nextArea, nextArea.side_area]
        person.nextLine = AreaHandler.getNextLineOfCharacter(person)
        
        var newCollision = ["+1", Color.ORANGE, person.global_position, person]
        scoreTexts.append(newCollision)

var scoreTexts : Array = []
# [["TEXT", Color, Vector2, Collider], ["COLLIDE", Color, Vector2, TileMap]]
@onready var default_font = load("res://Resources/FONTS/november.tres")

var size = 10

func _draw():
    for i in scoreTexts:
        self.draw_string(default_font, i[2] - self.global_position, i[0], HORIZONTAL_ALIGNMENT_LEFT, -1, size, i[1])
        
        var newThread = Thread.new()
        newThread.start(func wait():
            await self.get_tree().create_timer(1).timeout
            scoreTexts.erase(i), Thread.PRIORITY_HIGH)
        newThread.wait_to_finish()	

func Exited(person):
    # print(person.name, " exited ", self.name)
    inside.erase(person.name)

@onready var collider : CollisionShape2D = get_node("CollisionShape2D")

func _ready():
    if not collider:
        push_error("ERROR: Area has no collision detection!")
    body_entered.connect(Entered)
    body_exited.connect(Exited)
    z_index = 3
    
func _process(_delta):
    self.queue_redraw()
