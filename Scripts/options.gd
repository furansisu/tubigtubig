extends Control

var drawDebug = false
var changeCharacter = true
var changeTeam = false
var totalRounds = 3

var mainMenu = null
var pauseMenu = false

func setupAsPause():
	pauseMenu = true
	mainMenu = get_parent().get_node("MainMenu")
	self.hide()

# Called when the node enters the scene tree for the first time.
func _ready():
	if self.get_children().is_empty() == false:
		%Debug.button_pressed = Options.drawDebug
		%ChangeChar.button_pressed = Options.changeCharacter
		%ChangeTeam.button_pressed = Options.changeTeam
		%Round.value = Options.totalRounds
		%RoundLabel.text = "Total Rounds: " + str(Options.totalRounds)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_debug_toggled(button_pressed):
	Options.drawDebug = button_pressed
	print("Set debug to " + str(button_pressed))


func _on_change_char_toggled(button_pressed):
	Options.changeCharacter = button_pressed


func _on_change_team_toggled(button_pressed):
	Options.changeTeam = button_pressed

func _on_back_pressed():
	if pauseMenu:
		self.hide()
		mainMenu.show()
	else:
		get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_round_value_changed(value):
	Options.totalRounds = value
	%RoundLabel.text = "Total Rounds: " + str(%Round.value)
