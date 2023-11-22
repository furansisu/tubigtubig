extends CanvasLayer

@onready var TEAM1 = %TEAM1
@onready var TEAM2 = %TEAM2

func scored(value):
	TEAM1.text = "Team 1: " + str(value)
