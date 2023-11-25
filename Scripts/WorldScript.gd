extends Node2D

var selectedTeam : Array
var allChars = []
var numchar = 0
var Moving
var ManualMove = false

@onready var AreaHandler = get_node("/root/World/PlayingAreas")

@onready var players = %Players
@onready var cam = $Camera
@onready var ui = %UI
@onready var Team1Score = 0
@onready var Team2Score = 0
var lerpspeed = .1

@export var Team1 : Array = []
@export var Team2 : Array = []
@export var Runners : Array = []
@export var Taggers : Array = []

var maxPlayersInTeam = 3

signal Scored
signal Caught

var selectedChar = 0
@export var CurrentlySelected: CharacterBody2D

var loads = []

func _ready():
	for player in players.get_children():
		var fname = player.scene_file_path
		var loaded = load(fname)
		loads.append(loaded)
	
	gameSetup()
	Scored.connect(score)
	Caught.connect(tagged)

func gameSetup():
	for i in players.get_children():
		allChars.append(i)
		numchar += 1
	
	InitialTeamSetup(Team1)
	InitialTeamSetup(Team2)
	
	var random = randi_range(1,2)
	match random:
		1:
			Runners = Team1.duplicate()
			Taggers = Team2.duplicate()
		2:
			Taggers = Team1.duplicate()
			Runners = Team2.duplicate()
	
	runnersSet(Runners)
	taggersSet(Taggers)
	
	selectedTeam = Runners
	print(selectedTeam.hash() == Runners.hash())
	cam.reparent(selectedTeam[selectedChar])
	CurrentlySelected = selectedTeam[selectedChar]
	CurrentlySelected.Selected.emit(true)
	cam.position = Vector2(0, 0)

var Temp = []
func switchTeams():
	Runners = Taggers.duplicate()
	Taggers = Temp.duplicate()
	
	print(Runners)
	print(Taggers)
	
	runnersSet(Runners)
	taggersSet(Taggers)

func grabRandomAreaPos():
	var random = randi_range(1,2)
	var area : Area
	
	match random:
		1:
			area = AreaHandler.get_node("StartingLeft")
		2:
			area = AreaHandler.get_node("StartingRight")
			
	return AreaHandler.random_pos(area)

func InitialTeamSetup(team : Array):
	for m in maxPlayersInTeam:
		if allChars.is_empty():
			break
		var picked = allChars.pick_random()
		team.append(picked)
		allChars.erase(picked)

func taggersSet(team : Array):
	var teamName = "Taggers"
	var emptyTeam = team.duplicate()
	var lines = get_node("Lines").get_children()
	for i in lines:
		if i.name == "MiddleLine":
			lines.erase(i)
	for i in lines:
		if emptyTeam.is_empty():
			break
		var player : CharacterBody2D = emptyTeam.pick_random()
		player.currentLine = i
		player.global_position = i.global_position
		player.set_collision_layer(i.get_collision_layer()+1)
		player.set_collision_mask(i.get_collision_mask()+1)
		emptyTeam.erase(player)
	for player in team:
		print("Set " + player.name + " to " + teamName + " team")
		player.currentTeam = teamName
		player.setupReady.emit()
		
func runnersSet(team : Array):
	Temp = []
	var teamName = "Runners"
	for player in team:
		player.global_position = grabRandomAreaPos()
		player.set_collision_layer(1)
		player.set_collision_mask(1)
		print("Set " + player.name + " to " + teamName + " team")
		player.currentTeam = teamName
		player.setupReady.emit()

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

var slowDownTimer = 0
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
		
	slowDownTimer -= delta
	if slowDownTimer <= 0:
		Engine.time_scale = 1

func _physics_process(_delta):
	cam.position = lerp(cam.position, Vector2(0, 0), lerpspeed)

func score(player):
	var team = 1
	for i in Team2:
		if i.name == player.name:
			team = 2
	
	match team:
		1:
			Team1Score += 1
			ui.scored(Team1Score, 1)
		2:
			Team2Score += 1
			ui.scored(Team2Score, 2)
	
func gameEnd():
	ui.endGame()
#	switchTeams()

func tagged(caught : CharacterBody2D, tagger : CharacterBody2D):
	slowDown(0.1)
	
	print(caught.name + " WAS CAUGHT BY " + tagger.name)
	
	for i in Runners:
		if i.name == caught.name:
			Temp.append(i)
			Runners.erase(i)
			print(selectedTeam.hash() == Runners.hash())
	
	caught.Caught = true
	
	if caught == CurrentlySelected:
		changeCharacter()

func slowDown(time):
	slowDownTimer = time
	Engine.time_scale = 0.1
	print("Slowing down time")

func changeCharacter():
	print("Changed character")
	CurrentlySelected.Selected.emit(false)
	if selectedTeam.size() == 0:
		print("GAME IS OVER!!")
		
		gameEnd()
		return
	
	if selectedChar == selectedTeam.size()-1:
		selectedChar = 0
	else:
		selectedChar += 1
	if selectedChar > selectedTeam.size()-1:
		selectedChar = 0
	
	CurrentlySelected = selectedTeam[selectedChar]
	CurrentlySelected.Selected.emit(true)
	cam.reparent(CurrentlySelected)
	slowDown(0.05)

func changeTeam():
	print("Changed team")
	if selectedTeam.hash() == Team1.hash():
		selectedTeam = Team2
	else:
		selectedTeam = Team1
	selectedChar = maxPlayersInTeam-1
	changeCharacter()
