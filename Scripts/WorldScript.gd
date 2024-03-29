extends Node2D
enum {RUNNER, TAGGER, RANDOM}

var default_font = load("res://Resources/FONTS/PixelEmulator-xq08.ttf")

var selectedTeam : Array
var allChars = []
var numchar = 0
var Moving
var ManualMove = false

@onready var AreaHandler = get_node("/root/World/PlayingAreas")
@onready var joystick = get_node("/root/World/UI/MobileControls/joystick")
@onready var gameTimeLength = 120

@onready var players = %Players
@onready var cam = $Camera
@onready var ui = %UI
@onready var Team1Score = 0
@onready var Team2Score = 0
var lerpspeed = .1

@export var Team1 : Array = []
@export var Team2 : Array = []
@export var Runners : Array = []
@export var RunnersOnField : Array = []
@export var Taggers : Array = []

@onready var rounds = 1
@export var currentRound = 0

var roundSwitch = false

var maxPlayersInTeam = 3

signal Scored
signal Caught

var selectedChar = 0
@export var CurrentlySelected: CharacterBody2D

func _ready():
    cam.global_position = Vector2(0, 0)
    
    ui.showSelectTeam()
    ui.team_selected.connect(gameSetup)
    Scored.connect(score)
    Caught.connect(tagged)

var lastSelected = ""
func gameSetup():
    for i in players.get_children():
        allChars.append(i)
        numchar += 1
    
    InitialTeamSetup(Team1)
    InitialTeamSetup(Team2)
    
    Runners = Team1.duplicate()
    Taggers = Team2.duplicate()
    
    runnersSet(Runners)
    taggersSet(Taggers)
    
    if ui.chosenTeam == RUNNER:
        selectedTeam = RunnersOnField
        lastSelected = "Runners"
    elif ui.chosenTeam == TAGGER:
        selectedTeam = Taggers
        lastSelected = "Taggers"
    elif ui.chosenTeam == RANDOM:
        var rng = RandomNumberGenerator.new()
        var num = rng.randi_range(1,2)
        match num:
            1:
                selectedTeam = RunnersOnField
                lastSelected = "Runners"
            2:
                selectedTeam = Taggers
                lastSelected = "Taggers"
    
    ui.setupTeammateUI(Team1, Team2)
    
    print(selectedTeam.hash() == Runners.hash())
    cam.reparent(selectedTeam[selectedChar])
    CurrentlySelected = selectedTeam[selectedChar]
    CurrentlySelected.Selected.emit(true)
    cam.position = Vector2(0, 0)
    
    ui.start_game_timer(3)
    ui.game_timer(gameTimeLength)
    ui.get_node("Timer").timeout.connect(gameEnd)

func reloadTeams():
    for player in players.get_children():
        player.reset()

var Temp = []
func switchTeams():
    reloadTeams()
    
    print(" SWITCHING -----------------")
    Temp = Runners.duplicate()
    Runners = Taggers.duplicate()
    Taggers = Temp.duplicate()
    
    print("Runners: ")
    print(Runners)
    print("Taggers: ")
    print(Taggers)
    
    runnersSet(Runners)
    taggersSet(Taggers)
    
    if lastSelected == "Runners":
        selectedTeam = Taggers
        lastSelected = "Taggers"
    elif lastSelected == "Taggers":
        selectedTeam = RunnersOnField
        lastSelected = "Runners"
    
    selectedChar = selectedChar
    changeCharacter(true)
    
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
        player.set_collision_layer(i.get_collision_layer()+512)
        player.set_collision_mask(i.get_collision_mask()+1024)
        emptyTeam.erase(player)
    for player in team:
#		print("Set " + player.name + " to " + teamName + " team")
        player.Caught = false
        player.currentTeam = teamName
        player.setupReady.emit()

func runnersSet(team : Array):
    RunnersOnField = Runners.duplicate()
    var teamName = "Runners"
    for player : CharacterBody2D in team:
        player.global_position = grabRandomAreaPos()
        player.set_collision_layer(1)
        player.set_collision_mask(513+1024) # 9 AND 1
#		print("Set " + player.name + " to " + teamName + " team")
        player.currentTeam = teamName
        player.Caught = false
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
            changeCharacter(false)
        timer = 0
    if ev.is_action_pressed("click"):
        pass
        #CurrentlySelected.MoveTo(get_global_mouse_position(), null)
    if ev.is_action_pressed("run"):
        CurrentlySelected.running = true
    if ev.is_action_released("run"):
        CurrentlySelected.running = false
    if ev.is_action_pressed("dash"):
        CurrentlySelected.dash()

var slowDownTimer = 0
var gameEndCalled = false
func _process(delta):
    if slowDownTimer > 0:
        slowDownTimer -= delta
    else:
        Engine.time_scale = 1
    
    if RunnersOnField.is_empty() and not gameEndCalled:
        gameEnd()
    elif gameEndCalled:
        return
    
    if holdingChangeCharacter:
        timer += delta
        if timer >= waitTime:
            changeTeam()
            holdingChangeCharacter = false
    var direction = Input.get_vector("left", "right", "up", "down") + joystick.posVector
    if ManualMove:
        CurrentlySelected.Move(direction, CurrentlySelected.defaultspd)
    if direction == Vector2.ZERO and ManualMove:
        ManualMove = false
    if direction != Vector2.ZERO and not ManualMove:
        ManualMove = true
    
    if tagCooldown > 0:
        tagCooldown -= delta
    
    cam.position = lerp(cam.position, Vector2(0, 0), (lerpspeed * delta * 100)/Engine.time_scale)

func score(player):
    $Point.play()
    var team = 1
    for i in Team2:
        if i.name == player.name:
            team = 2
    
    match team:
        1:
            for i in Team1:
                if i == CurrentlySelected:
                    Team1Score += 1
                    ui.scored(Team1Score, 1)
                    return
            Team2Score += 1
            ui.scored(Team2Score, 2)
        2:
            for i in Team2:
                if i == CurrentlySelected:
                    Team1Score += 1
                    ui.scored(Team1Score, 1)
                    return
            Team2Score += 1
            ui.scored(Team2Score, 2)

var tagCooldown = 0
var lastGameStartTick = 0

func gameEnd():
    $GameOver.play()
    gameEndCalled = true
    print(" GAME END! ")
    if roundSwitch:
        currentRound += 1
        roundSwitch = false
    else:
        roundSwitch = true
    rounds = Options.totalRounds
    if currentRound == rounds:
        ui.endGame()
        return
    await ui.switching_teams()
    switchTeams()
    await ui.start_game_timer(3)
    ui.game_timer(gameTimeLength)
    gameEndCalled = false
    lastGameStartTick = Time.get_ticks_msec()
    tagCooldown = 1

func tagged(caught : CharacterBody2D, _tagger : CharacterBody2D, pos : Vector2):
    if not gameEndCalled and tagCooldown > 0:
        return
    slowDown(0.1)
    $Tag.play()
    
#	print(caught.name + " WAS CAUGHT BY " + tagger.name)
    
    for i in RunnersOnField:
        if i.name == caught.name:
            RunnersOnField.erase(i)
    
    caught.Caught = true
    
    if caught == CurrentlySelected:
        changeCharacter(true)
        
    if RunnersOnField.size() == 1:
        RunnersOnField[0].LastPerson = true

func slowDown(time):
    slowDownTimer = time
    Engine.time_scale = 0.1
#	print("Slowing down time")

func changeCharacter(forced):
    if not Options.changeCharacter and not forced: return
    print("Changed character")
    CurrentlySelected.Selected.emit(false)
    if selectedTeam.size() == 0:
        print("GAME IS OVER!!")
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
    print("SELECTED NUMBER: " + str(selectedChar))
    if selectedTeam.size() == 1:
        return
    slowDown(0.05)

func changeTeam():
    if not Options.changeTeam: return
    print("Changed team")
    if selectedTeam.hash() == RunnersOnField.hash():
        selectedTeam = Taggers
        lastSelected = "Taggers"
    else:
        selectedTeam = RunnersOnField
        lastSelected = "Runners"
    selectedChar = maxPlayersInTeam-1
    changeCharacter(true)
