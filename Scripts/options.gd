extends Control

var drawDebug = false
var changeCharacter = true
var changeTeam = false

# Called when the node enters the scene tree for the first time.
func _ready():
	if get_tree().current_scene == self:
		%Debug.button_pressed = drawDebug
		%ChangeChar.button_pressed = changeCharacter
		%ChangeTeam.button_pressed = changeTeam

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
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
