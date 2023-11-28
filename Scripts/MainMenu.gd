extends Control

var optionsMenu = null
var pauseMenu = false
signal Resume

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setupAsPause():
	pauseMenu = true
	%Play.text = "RESUME"
	%Play.defaultText = "RESUME"
	self.hide()
	optionsMenu = get_parent().get_node("Options")

func _on_play_pressed():
	if not pauseMenu:
		get_tree().change_scene_to_file("res://Scenes/World.tscn")
	else:
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
