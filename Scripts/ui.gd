extends CanvasLayer

@onready var PauseMenu = preload("res://Scenes/main_menu.tscn").instantiate()
@onready var OptionsMenu = preload("res://Scenes/options.tscn").instantiate()
@onready var Tutorial = preload("res://Scenes/tutorial.tscn").instantiate()
@onready var PlayerContainer = preload("res://Scenes/ui/playerui.tscn")

@onready var TEAM1 = %TEAM1
@onready var TEAM2 = %TEAM2
@onready var SWITCH = %SWITCH
@onready var STARTING = %STARTING
@onready var GO = %GO
@onready var TEAM1CONTAINERS = %Team1Players
@onready var TEAM2CONTAINERS = %Team2Players

@onready var GRAY = %GRAY

# Variables
var switch_team_length = 1
var game_starting_timer = 0
var main_timer = 0

var go_max_time = 1
var go_timer = 0

var paused2 = false

func _ready():
    self.add_child(PauseMenu)
    self.add_child(OptionsMenu)
    self.add_child(Tutorial)
    PauseMenu.setupAsPause()
    PauseMenu.Resume.connect(PAUSEFUNC)
    print(OptionsMenu.name)
    OptionsMenu.setupAsPause()
    Tutorial.setupAsPause()
    %click.play()

func scored(value, team):
    match team:
        1:
            TEAM1.text = "YOUR TEAM: " + str(value)
        2:
            TEAM2.text = "\nENEMY TEAM: " + str(value)
            
func setupTeammateUI(Team1 : Array, Team2 : Array):
    for teammate in Team1:
        var teammateUI = PlayerContainer.instantiate()
        TEAM1CONTAINERS.get_node("VBoxContainer").add_child(teammateUI)
        var nameUI : Label = teammateUI.get_node("Control").get_node("Name")
        nameUI.text = teammate.name
    for teammate in Team2:
        var teammateUI = PlayerContainer.instantiate()
        TEAM2CONTAINERS.get_node("VBoxContainer").add_child(teammateUI)
        var nameUI : Label = teammateUI.get_node("Control").get_node("Name")
        nameUI.text = teammate.name
            
func _input(ev):
    if ev.is_action_pressed("pause"):
        PAUSEFUNC()

func _physics_process(delta):
    if paused2: return
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
    
    var minutes = str(int(%Timer.time_left/60))
    var seconds = str(int(%Timer.time_left)%60)
    if int(seconds) < 10:
        seconds = "0" + seconds
    %TIMERUI.text = minutes + ":" + seconds

func endGame():
    %Timer.paused = true
    %GAMEOVER.show()
    await get_tree().create_timer(2).timeout
    for button in %GAMEOVER.get_children():
        await get_tree().create_timer(1).timeout
        button.show()

func PAUSEFUNC():
    if not paused2:
        %hover.play()
        GRAY.show()
        %TEAM1.hide()
        %TEAM2.hide()
        %GO.hide()
        STARTING.hide()
        print("PAUSING")
        PauseMenu.show()
    else:
        %back.play()
        GRAY.hide()
        %TEAM1.show()
        %TEAM2.show()
        if game_starting_timer > 0:
            STARTING.show()
        print("UNPAUSING")
        PauseMenu.hide()
    get_tree().paused = !paused2
    paused2 = !paused2

func switching_teams():
    GRAY.show()
    SWITCH.show()
    await get_tree().create_timer(switch_team_length * Engine.time_scale).timeout
    GRAY.hide()
    SWITCH.hide()

func start_game_timer(length: int):
    game_starting_timer = float(length)
    STARTING.show()
    
func game_timer(length: int):
    %Timer.start(length)


func _on_try_again_pressed():
    get_tree().change_scene_to_file("res://Scenes/World.tscn")

func _on_quit_pressed():
    get_tree().quit()
