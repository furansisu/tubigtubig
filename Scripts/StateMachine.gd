extends Node

@export var initial_state : State
@onready var AreaHandler = get_node("/root/World/PlayingAreas")
@onready var level = get_node("/root/World")

var character : CharacterBody2D

@export var current_state : State
var states : Dictionary = {}

func _ready():
	character = get_parent()
	character.Selected.connect(onSelect)
	character.targetArea = AreaHandler.setStartingArea()
	var nextArea = AreaHandler.getNextAreaOfCharacter(character)
	var nextLine = AreaHandler.getNextLineOfCharacter(character)
	character.nextScoreArea = [nextArea, nextArea.side_area]
	character.nextLine = nextLine
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.Transitioned.connect(on_child_transition)
	
	character.setupReady.connect(setInitialState)
	level.Caught.connect(onTagged)

func setInitialState():
	if character.currentTeam == "Runners":
		initial_state = get_node("Strafe")
	if character.currentTeam == "Taggers":
		initial_state = get_node("Guard")
	if initial_state:
		initial_state.Enter()
		current_state = initial_state
	
	print("COLLISION MASK FOR " + character.name + ": " + str(character.get_collision_mask()))
#	print("Entering initial state for " + character.name + ": " + initial_state.name)
	
func _process(delta):
	if current_state:
		current_state.Update(delta)
		
func _physics_process(delta):
	if current_state:
		current_state.Physics_Update(delta)
		
func on_child_transition(state, new_state_name):
	if state == null:
		push_error("NO INITIAL STATE SET")
#	print(character.name, " has transitioned from ", state.name, " to ", new_state_name)
	if state != current_state:
		return
		
	var new_state = states.get(new_state_name)
	if not new_state:
		return
	
	if current_state:
		current_state.Exit()
	
	new_state.Enter()
	current_state = new_state

func onTagged(caught : CharacterBody2D, tagger : CharacterBody2D):
	if not level.gameEndCalled and level.tagCooldown > 0:
		return
	
	if caught == character:
		print(character.name + " was caught by " + tagger.name + " | " + str((Time.get_ticks_msec()-level.lastGameStartTick)/1000))
		on_child_transition(current_state, "OutOfGame")

func onSelect(selectedBool):
	if character.Caught == true:
		return
	if selectedBool == true:
		print(character.name + " was selected!")
		on_child_transition(current_state, "Disable")
		if character.currentLine:
			if character.currentLine.name == "Line1":
				var middleLine = get_node("/root/World/MiddleLinePlayer")
				character.set_collision_mask(middleLine.get_collision_mask()+1)
	else:
		if character.currentTeam == "Runners":
			on_child_transition(current_state, "Strafe")
		if character.currentTeam == "Taggers":
			on_child_transition(current_state, "Guard")

func reset():
	character.targetArea = AreaHandler.setStartingArea()
	var nextArea = AreaHandler.getNextAreaOfCharacter(character)
	var nextLine = AreaHandler.getNextLineOfCharacter(character)
	character.nextScoreArea = [nextArea, nextArea.side_area]
	character.nextLine = nextLine
	on_child_transition(current_state, "Disable")
