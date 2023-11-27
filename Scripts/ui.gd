extends CanvasLayer

@onready var TEAM1 = %TEAM1
@onready var TEAM2 = %TEAM2
@onready var PAUSE = %PauseMenu
@onready var SWITCH = %SWITCH
@onready var STARTING = %STARTING
@onready var GO = %GO

@onready var GRAY = %GRAY

# Variables
var switch_team_length = 1
var game_starting_timer = 0

var go_max_time = 1
var go_timer = 0

func _ready():
	var button = PAUSE.get_node("MarginContainer/Button")
	button.pressed.connect(PAUSEFUNC)

func scored(value, team):
	match team:
		1:
			TEAM1.text = "Team 1: " + str(value)
		2:
			TEAM2.text = "\nTeam 2: " + str(value)
	
func _input(ev):
	if ev.is_action_pressed("pause"):
		PAUSEFUNC()

func _physics_process(delta):
	if game_starting_timer > 0:
		GRAY.show()
		get_tree().paused = true
		game_starting_timer = clampf(game_starting_timer - (delta/Engine.time_scale), 0, INF)
		STARTING.text = "STARTING GAME IN\n" + str((floor(game_starting_timer + 1)))
		if game_starting_timer <= 0:
			STARTING.hide()
			GO.show()
			get_tree().paused = false
			GRAY.hide()
	if GO.visible:
		go_timer += delta
		if go_timer >= go_max_time:
			GO.hide()
			go_timer = 0

func endGame():
	get_tree().paused = true
	%GAMEOVER.show()

func PAUSEFUNC():
	var paused = get_tree().paused
	if not paused:
		GRAY.show()
		print("PAUSING")
		PAUSE.show()
	else:
		GRAY.hide()
		print("UNPAUSING")
		PAUSE.hide()
	get_tree().paused = !paused

func switching_teams():
	GRAY.show()
	SWITCH.show()
	await get_tree().create_timer(switch_team_length * Engine.time_scale).timeout
	GRAY.hide()
	SWITCH.hide()

func start_game_timer(length: int):
	game_starting_timer = float(length)
	STARTING.show()
	
	
