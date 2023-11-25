extends CanvasLayer

@onready var TEAM1 = %TEAM1
@onready var TEAM2 = %TEAM2
@onready var PAUSE = %PauseMenu

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

func endGame():
	get_tree().paused = true
	%GAMEOVER.show()

func PAUSEFUNC():
	var paused = get_tree().paused
	if not paused:
		print("PAUSING")
		PAUSE.show()
	else:
		print("UNPAUSING")
		PAUSE.hide()
	get_tree().paused = !paused
