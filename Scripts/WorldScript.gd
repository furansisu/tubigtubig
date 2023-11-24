extends Node2D

var selectedTeam : Array
var allChars = []
var numchar = 0
var Moving
var ManualMove = false

@onready var cam = $Camera
@onready var ui = %UI
@onready var Team1Score = 0
@onready var Team2Score = 0
var lerpspeed = .1

@export var Team1 : Array = []
@export var Team2 : Array = []
@export var Runners = Team1
@export var Taggers = Team2

var maxPlayersInTeam = 3

signal Scored

var selectedChar = 0
@export var CurrentlySelected: CharacterBody2D

func _ready():
	for i in get_node("Players").get_children():
		allChars.append(i)
		numchar += 1
	print(allChars)
	
	TeamSetup(Team1)
	TeamSetup(Team2)
	
	selectedTeam = Team1
	
	cam.reparent(selectedTeam[selectedChar])
	CurrentlySelected = selectedTeam[selectedChar]
	CurrentlySelected.Selected.emit(true)
	cam.position = Vector2(0, 0)
	
	Scored.connect(score)

func TeamSetup(team : Array):
	for m in maxPlayersInTeam:
		if allChars.is_empty():
			break
		var picked = allChars.pick_random()
		team.append(picked)
		allChars.erase(picked)
	var teamName
	var lineSetup = false
	if team.hash() == Runners.hash():
		teamName = "Runners"
	if team.hash() == Taggers.hash():
		teamName = "Taggers"
		lineSetup = true
	if lineSetup:
		lineSet(team)
	print(team)
	for player in team:
		print("Set " + player.name + " to " + teamName + " team")
		player.currentTeam = teamName
		player.setupReady.emit()

func lineSet(team : Array):
	var emptyTeam = team.duplicate()
	var lines = get_node("Lines").get_children()
	for i in lines:
		if i.name == "MiddleLine":
			lines.erase(i)
	for i in lines:
		if emptyTeam.is_empty():
			break
		var player = emptyTeam.pick_random()
		player.currentLine = i
		player.global_position = i.global_position
		emptyTeam.erase(player)
	print(team)

var timer = 0
var waitTime = 1 # seconds
var holdingChangeCharacter = false
func _input(ev : InputEvent):
	if ev.is_action_pressed("changechar"):
		holdingChangeCharacter = true
	if ev.is_action_released("changechar"):
		holdingChangeCharacter = false
		if timer < waitTime:
			changeCharacter()
		timer = 0
	if ev.is_action_pressed("click"):
		CurrentlySelected.MoveTo(get_global_mouse_position(), null)
	if ev.is_action_pressed("run"):
		CurrentlySelected.RunBool(true)
	if ev.is_action_released("run"):
		CurrentlySelected.RunBool(false)

func _process(delta):
	if holdingChangeCharacter:
		timer += delta
		if timer > waitTime:
			changeTeam()
			holdingChangeCharacter = false
	var direction = Input.get_vector("left", "right", "up", "down")	
	if ManualMove:
		CurrentlySelected.Move(direction, CurrentlySelected.defaultspd)
	if direction == Vector2.ZERO and ManualMove:
		ManualMove = false
	if direction != Vector2.ZERO and not ManualMove:
		ManualMove = true

func _physics_process(_delta):
	cam.position = lerp(cam.position, Vector2(0, 0), lerpspeed)

func score():
	Team1Score += 1
	ui.scored(Team1Score)
	
func changeCharacter():
	print("Changed character")
	CurrentlySelected.Selected.emit(false)
	if selectedChar == maxPlayersInTeam-1:
		selectedChar = 0
	else:
		selectedChar += 1
	if selectedTeam[selectedChar] == null:
		selectedChar = 0
	
	CurrentlySelected = selectedTeam[selectedChar]
	CurrentlySelected.Selected.emit(true)
	cam.reparent(CurrentlySelected)

func changeTeam():
	print("Changed team")
	if selectedTeam.hash() == Team1.hash():
		selectedTeam = Team2
	else:
		selectedTeam = Team1
	selectedChar = maxPlayersInTeam-1
	changeCharacter()
