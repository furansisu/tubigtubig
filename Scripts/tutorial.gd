extends Control
var currentPage = 1
var pauseMenu = false
var mainMenu

# Called when the node enters the scene tree for the first time.
func _ready():
    changePage(currentPage)

func changePage(page):
    if page != 18:
        get_node("page"+str(currentPage)).hide()
        get_node("page"+str(page)).show()
        currentPage = page
    else:
        back()

func setupAsPause():
    pauseMenu = true
    mainMenu = get_parent().get_node("MainMenu")
    self.hide()

func back():
    Back.play()
    if pauseMenu == true:
        changePage(1)
        self.hide()
        mainMenu.show()
    else:
        print("Tutorial is returning to main menu")
        get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _input(ev : InputEvent):
    if visible == false: return
    if ev.is_action_pressed("pause"):
        back()
    if ev is InputEventMouseButton and ev.is_released():
        changePage(currentPage+1)
        %click.play()
        
