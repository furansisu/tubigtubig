extends Control

var optionsMenu = null
var tutorial = null
var pauseMenu = false
@onready var music = get_node("Music")
signal Resume

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setupAsPause():
	music.playing = false
	pauseMenu = true
	%Play.text = "RESUME"
	%Play.defaultText = "RESUME"
	%GRAY.hide()
	%Background.hide()
	self.hide()
	optionsMenu = get_parent().get_node("Options")
	tutorial = get_parent().get_node("pages")

func _on_play_pressed():
	if not pauseMenu:
		get_tree().change_scene_to_file("res://Scenes/World.tscn")
	else:
		resumeGame()

func resumeGame():
	Resume.emit()
	self.hide()

func _on_quit_button_down():
	get_tree().quit()

func _on_options_pressed():
	if not pauseMenu:
		get_tree().change_scene_to_file("res://Scenes/options.tscn")
	else:
		self.hide()
		optionsMenu.show()

func _on_tutorial_pressed():
	if not pauseMenu:
		get_tree().change_scene_to_file("res://Scenes/tutorial.tscn")
	else:
		self.hide()
		tutorial.show()
